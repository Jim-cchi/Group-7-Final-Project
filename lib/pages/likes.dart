import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'video_player_screen.dart'; // Import the new screen

class MyLikes extends StatefulWidget {
  const MyLikes({super.key});

  @override
  State<MyLikes> createState() => _MyLikesState();
}

class _MyLikesState extends State<MyLikes> with WidgetsBindingObserver {
  final DatabaseReference _userLikesRef =
      FirebaseDatabase.instance.ref().child('userLikes');
  final DatabaseReference _shortsRef =
      FirebaseDatabase.instance.ref().child('shorts');

  List<VideoData> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchLikedVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchLikedVideos(); // Refresh data when screen is resumed
    }
  }

  Future<void> _fetchLikedVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userLikesSnapshot = await _userLikesRef.child(userId).get();
      if (!userLikesSnapshot.exists) {
        setState(() {
          _videos = [];
          _isLoading = false;
        });
        return;
      }

      final videoKeys = (userLikesSnapshot.value as Map<Object?, dynamic>)
          .keys
          .where((key) => key != null)
          .map((key) => key as String)
          .toList();

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
            thumbnailUrl: video['thumbnailUrl'] ?? '',
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
          : _videos.isEmpty
              ? Center(
                  child: Text(
                    'No liked videos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
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
                            _fetchLikedVideos()); // Refresh data when returning
                      },
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.fill,
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
  final String thumbnailUrl;

  VideoData({
    this.key,
    required this.url,
    required this.description,
    this.user,
    this.likes = 0,
    required this.dateAdded,
    this.thumbnailUrl = "",
  });
}
