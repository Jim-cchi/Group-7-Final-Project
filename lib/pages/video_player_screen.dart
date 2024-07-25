import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String description;
  final String user;
  final int initialLikes;
  final String videoKey;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.description,
    required this.user,
    required this.initialLikes,
    required this.videoKey,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isLiked = false;
  late int _likes;
  bool _showPlayPauseIcon = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true); // Loop the video
      });

    _likes = widget.initialLikes;
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userLikeRef = FirebaseDatabase.instance
        .ref()
        .child('userLikes/$userId/${widget.videoKey}');
    final userLikeSnapshot = await userLikeRef.get();

    setState(() {
      _isLiked = userLikeSnapshot.exists;
    });
  }

  Future<void> _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final videoRef =
        FirebaseDatabase.instance.ref().child('shorts/${widget.videoKey}');
    final userLikeRef = FirebaseDatabase.instance
        .ref()
        .child('userLikes/$userId/${widget.videoKey}');
    final videoSnapshot = await videoRef.get();
    final userLikeSnapshot = await userLikeRef.get();

    if (videoSnapshot.exists) {
      final videoData = videoSnapshot.value as Map<dynamic, dynamic>;
      bool isLiked = userLikeSnapshot.exists;

      setState(() {
        if (isLiked) {
          _likes -= 1;
          userLikeRef.remove();
        } else {
          _likes += 1;
          userLikeRef.set(true);
        }
        _isLiked = !_isLiked;
      });

      await videoRef.update({'likes': _likes});
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
      _showPlayPauseIcon = true;

      // Hide the play/pause icon after 0.5 seconds
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showPlayPauseIcon = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              const Center(
                child: CircularProgressIndicator(),
              ),
            // User and Description Info
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Like Button
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_likes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Play/Pause Icon
            if (_showPlayPauseIcon)
              Center(
                child: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
