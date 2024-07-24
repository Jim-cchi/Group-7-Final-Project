import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyLikes extends StatefulWidget {
  const MyLikes({super.key});

  @override
  State<MyLikes> createState() => _MyLikesState();
}

class _MyLikesState extends State<MyLikes> {
  final DatabaseReference _userLikesRef =
      FirebaseDatabase.instance.ref().child('userLikes');
  final DatabaseReference _shortsRef =
      FirebaseDatabase.instance.ref().child('shorts');

  List<VideoData> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLikedVideos();
  }

  Future<void> _fetchLikedVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Fetch liked video keys
      final userLikesSnapshot = await _userLikesRef.child(userId).get();
      if (!userLikesSnapshot.exists) return;

      final videoKeys = (userLikesSnapshot.value as Map<Object?, dynamic>)
          .keys
          .where((key) => key != null)
          .map((key) => key as String)
          .toList();

      // Fetch video details
      final videos = <VideoData>[];
      for (var videoKey in videoKeys) {
        final videoSnapshot = await _shortsRef.child(videoKey).get();
        if (videoSnapshot.exists) {
          final video = videoSnapshot.value as Map<Object?, dynamic>;
          videos.add(VideoData(
            key: videoKey,
            url: video['url'] ?? '',
            description: video['description'] ?? '',
            user: video['user'] ?? 'No user',
            likes: video['likes'] ?? 0,
            dateAdded: DateTime.tryParse(
                    video['dateAdded'] ?? DateTime.now().toIso8601String()) ??
                DateTime.now(),
          ));
        }
      }

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching liked videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to a video player screen
                  },
                  child: Container(
                    color: Colors.lightBlue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            video.url, // Placeholder image
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            video.description,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            video.user ?? 'No user',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class VideoData {
  final String? key;
  final String url;
  final String description;
  final String? user;
  int likes;
  final DateTime dateAdded;

  VideoData({
    this.key,
    required this.url,
    required this.description,
    this.user,
    this.likes = 0,
    required this.dateAdded,
  });
}
