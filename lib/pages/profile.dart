import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'video_player_screen.dart'; // Import the new screen
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> with WidgetsBindingObserver {
  final DatabaseReference _shortsRef =
      FirebaseDatabase.instance.ref().child('shorts');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<VideoDataProfile> _videos = [];
  bool _isLoading = false;
  bool _isUploading = false; // New variable for upload state
  String? _username;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUserProfile();
    _fetchUserVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUserVideos(); // Refresh data when screen is resumed
    }
  }

  Future<void> _fetchUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.value as Map<Object?, dynamic>;
      setState(() {
        _username = userData['username'] ?? 'No username';
        _profileImageUrl = userData['profileImageUrl'] ??
            'https://via.placeholder.com/150'; // Placeholder URL
      });
    }
  }

  Future<void> _fetchUserVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot =
          await _shortsRef.orderByChild('userId').equalTo(userId).once();

      if (snapshot.snapshot.value == null) {
        setState(() {
          _videos = [];
          _isLoading = false;
        });
        return;
      }

      final videoData =
          Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      final videos = <VideoDataProfile>[];
      videoData.forEach((key, value) {
        final video = Map<String, dynamic>.from(value);
        videos.add(VideoDataProfile(
          key: key,
          url: video['url'] ?? '',
          description: video['description'] ?? '',
          user: video['user'] ?? 'No user',
          likes: video['likes'] ?? 0,
          dateAdded: DateTime.tryParse(
                  video['dateAdded'] ?? DateTime.now().toIso8601String()) ??
              DateTime.now(),
          thumbnailUrl: video['thumbnailUrl'] ?? '',
        ));
      });

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteVideo(String videoKey) async {
    try {
      final confirmation = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this video?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmation == true) {
        await _shortsRef.child(videoKey).remove();
        await _fetchUserVideos(); // Refresh list after deletion
      }
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _isUploading = true; // Start uploading
    });

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$userId');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId);
      await userRef.update({'profileImageUrl': downloadUrl});

      // Save the updated URL to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', downloadUrl);

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      print('Error uploading profile picture: $e');
    } finally {
      setState(() {
        _isUploading = false; // End uploading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_profileImageUrl ??
                              'https://via.placeholder.com/150'),
                          radius: 40,
                        ),
                        if (_isUploading)
                          const CircularProgressIndicator(), // Show loading indicator
                      ],
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _username ?? 'No username',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _uploadProfilePicture,
                  child: const Text('Change Profile Picture'),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey[800]),
                const SizedBox(height: 8),
                const Text(
                  'Your Videos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty
                    ? const Center(
                        child: Text(
                          'No videos found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        padding: const EdgeInsets.all(10),
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          final video = _videos[index];
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                        videoUrl: video.url,
                                        description: video.description,
                                        user: video.user!,
                                        initialLikes: video.likes,
                                        videoKey: video.key!,
                                      ),
                                    ),
                                  ).then((_) =>
                                      _fetchUserVideos()); // Refresh data when returning
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  child: Image.network(
                                    video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () => _deleteVideo(video.key!),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video.user ?? 'No user',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      video.description,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class VideoDataProfile {
  final String key;
  final String url;
  final String description;
  final String? user;
  final int likes;
  final DateTime dateAdded;
  final String thumbnailUrl;

  VideoDataProfile({
    required this.key,
    required this.url,
    required this.description,
    required this.user,
    required this.likes,
    required this.dateAdded,
    required this.thumbnailUrl,
  });
}
