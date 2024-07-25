import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyShorts extends StatefulWidget {
  const MyShorts({super.key});

  @override
  State<MyShorts> createState() => _MyShortsState();
}

class _MyShortsState extends State<MyShorts> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('shorts');
  final DatabaseReference _userLikesRef =
      FirebaseDatabase.instance.ref().child('userLikes');
  List<VideoData> _videos = [];
  bool _isLoading = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _databaseRef
          .orderByChild('dateAdded') // Order by newest
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<Object?, dynamic>;
        List<VideoData> fetchedVideos = data.entries.map((entry) {
          final video = entry.value as Map<Object?, dynamic>;
          return VideoData(
            key: entry.key as String?,
            url: video['url'] ?? '',
            description: video['description'] ?? '',
            user: video['user'] ?? 'No user', // Handle missing user field
            likes: video['likes'] ?? 0,
            dateAdded: DateTime.tryParse(
                    video['dateAdded'] ?? DateTime.now().toIso8601String()) ??
                DateTime.now(),
          );
        }).toList();

        // Sort by newest first
        fetchedVideos.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

        setState(() {
          _isLoading = false;
          _videos = fetchedVideos;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateBuffer(int index) {
    // Optionally load more videos if needed
  }

  Future<void> _toggleLike(VideoData video) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userLikeRef = _userLikesRef.child('$userId/${video.key}');

    final userLikeSnapshot = await userLikeRef.get();
    final bool isLiked = userLikeSnapshot.exists;

    // Update local state immediately
    setState(() {
      if (isLiked) {
        video.likes -= 1;
        userLikeRef.remove();
      } else {
        video.likes += 1;
        userLikeRef.set(true);
      }
    });

    // Update the Firebase database
    await _databaseRef.child('${video.key}/likes').set(video.likes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Stack(
        children: [
          _buildVideoPageView(),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical, // Ensure vertical scrolling
      controller: _pageController,
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return VideoItem(
          video: video,
          onLike: () => _toggleLike(video),
        );
      },
      onPageChanged: (index) {
        setState(() {
          _updateBuffer(index);

          // Pause all videos and play the currently visible video
          for (var video in _videos) {
            video.controller?.pause();
          }
          if (_videos.isNotEmpty && _videos[index].controller != null) {
            _videos[index].controller?.play();
          }
        });
      },
    );
  }
}

class VideoItem extends StatefulWidget {
  final VideoData video;
  final VoidCallback onLike;

  const VideoItem({required this.video, required this.onLike, super.key});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = true;
  bool _showPlayPause = true;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
          ..setLooping(true)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController.play();
          });

    // Fetch the like status for the current user
    _checkIfLiked();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showPlayPause = false;
        });
      }
    });
  }

  Future<void> _checkIfLiked() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userLikeRef = FirebaseDatabase.instance
        .ref()
        .child('userLikes/$userId/${widget.video.key}');
    final userLikeSnapshot = await userLikeRef.get();

    setState(() {
      _isLiked = userLikeSnapshot.exists;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying = !_isPlaying;
          _isPlaying
              ? _videoPlayerController.play()
              : _videoPlayerController.pause();
          _showPlayPause = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showPlayPause = false;
              });
            }
          });
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoPlayerController.value.isInitialized)
            AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_showPlayPause)
            Center(
              child: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 80,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.user ?? 'No user',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.video.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    widget.onLike();
                    setState(() {
                      _isLiked = !_isLiked; // Toggle the local like status
                    });
                  },
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                    size: 30,
                  ),
                ),
                Text(
                  '${widget.video.likes}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  VideoPlayerController? controller;

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
