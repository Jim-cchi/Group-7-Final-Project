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
  List<VideoData> _videos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _limit = 10; // Number of videos to fetch per page

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _databaseRef
          .orderByChild('likes') // Order by likes
          .limitToLast(_limit * (_page + 1))
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<Object?, dynamic>;
        List<VideoData> fetchedVideos = data.entries.map((entry) {
          final video = entry.value as Map<Object?, dynamic>;
          return VideoData(
            url: video['url'] ?? '',
            description: video['description'] ?? '',
            user: video['user'] ?? 'No user', // Handle missing user field
            likes: video['likes'] ?? 0,
            dateAdded: DateTime.tryParse(
                    video['dateAdded'] ?? DateTime.now().toIso8601String()) ??
                DateTime.now(),
          );
        }).toList();

        fetchedVideos.sort((a, b) {
          if (b.likes != a.likes) return b.likes.compareTo(a.likes);
          return b.dateAdded.compareTo(a.dateAdded);
        });

        setState(() {
          _isLoading = false;
          _hasMore = fetchedVideos.length == _limit * (_page + 1);
          _videos = fetchedVideos;
          _page++;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shorts'),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: Stack(
        children: [
          _buildVideoPageView(),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical, // Ensure vertical scrolling
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return VideoItem(video: video);
      },
      onPageChanged: (index) {
        _videos.forEach((video) {
          video.controller?.pause();
        });
        if (_videos.isNotEmpty && _videos[index].controller != null) {
          _videos[index].controller?.play();
        }
      },
    );
  }
}

class VideoItem extends StatefulWidget {
  final VideoData video;

  const VideoItem({required this.video, super.key});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = true;
  bool _showPlayPause = true;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
          ..setLooping(true) // Enable looping
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController
                .play(); // Start playback when the controller is initialized
          });

    // Hide play/pause icon after a short duration
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showPlayPause = false;
        });
      }
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
          _showPlayPause = true; // Show play/pause icon when tapped
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
            Center(
              child: CircularProgressIndicator(), // Loader while fetching
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
                Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 30,
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
  final String url;
  final String description;
  final String? user;
  final int likes;
  final DateTime dateAdded;
  VideoPlayerController? controller;

  VideoData({
    required this.url,
    required this.description,
    this.user,
    this.likes = 0,
    required this.dateAdded,
  });
}
