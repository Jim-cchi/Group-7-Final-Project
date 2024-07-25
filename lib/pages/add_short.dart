import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart' as cam;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vid_thumb;
import 'package:path_provider/path_provider.dart';

class MyAddShort extends StatefulWidget {
  const MyAddShort({super.key});

  @override
  State<MyAddShort> createState() => _MyAddShortState();
}

class _MyAddShortState extends State<MyAddShort> with WidgetsBindingObserver {
  List<cam.CameraDescription> cameras = [];
  cam.CameraController? cameraController;
  VideoPlayerController? videoPlayerController;
  bool isFrontCamera = true;
  bool isRecording = false;
  cam.XFile? videoFile;
  Duration recordingDuration = Duration.zero;
  Timer? timer;
  UploadTask? uploadTask;
  bool _isUploading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final dateAdded = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    videoPlayerController?.dispose();
    timer?.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            cam.CameraPreview(cameraController!),
            Positioned(
              top: 20,
              left: MediaQuery.of(context).size.width / 2 - 28,
              child: Text(
                _formatDuration(recordingDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 142,
              child: IconButton(
                onPressed:
                    isRecording ? _stopVideoRecording : _startVideoRecording,
                iconSize: 60,
                icon: Icon(
                  isRecording
                      ? Icons.stop_circle_outlined
                      : Icons.radio_button_checked,
                  color: Colors.red,
                ),
              ),
            ),
            !isRecording
                ? Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isFrontCamera = !isFrontCamera;
                          _setupCameraController();
                        });
                      },
                      iconSize: 40,
                      icon: const Icon(
                        Icons.flip_camera_android,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const SizedBox(),
            _isUploading
                ? SizedBox.expand(
                    child: Container(
                      color: const Color.fromARGB(144, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Please wait while video is uploading!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          buildProgress(),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    var cameras = await cam.availableCameras();
    if (cameras.isNotEmpty) {
      setState(() {
        cameras = cameras;
        cameraController = cam.CameraController(
          isFrontCamera ? cameras.last : cameras.first,
          cam.ResolutionPreset.high,
        );
      });
      await cameraController?.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _startVideoRecording() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        isRecording) {
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      setState(() {
        isRecording = true;
        recordingDuration = Duration.zero;
        timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            recordingDuration += const Duration(seconds: 1);
          });
          if (recordingDuration >= const Duration(minutes: 1)) {
            _stopVideoRecording();
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return;
    }
    try {
      final video = await cameraController!.stopVideoRecording();
      setState(() {
        isRecording = false;
        timer?.cancel();
        videoFile = video;
      });
      _showVideoPlayer();
    } catch (e) {
      print(e);
    }
  }

  void _showVideoPlayer() {
    if (videoFile != null) {
      videoPlayerController = VideoPlayerController.file(File(videoFile!.path))
        ..initialize().then((_) {
          setState(() {});
          videoPlayerController!.play();
          _showVideoDialog();
        });
    }
  }

  void _showVideoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Review Video"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                videoPlayerController != null &&
                        videoPlayerController!.value.isInitialized
                    ? Column(
                        children: [
                          AspectRatio(
                            aspectRatio:
                                videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(videoPlayerController!),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  videoPlayerController!.seekTo(Duration.zero);
                                  videoPlayerController!.play();
                                },
                                child: const Text("Replay"),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 5),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Enter a description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  videoPlayerController?.pause();
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  videoPlayerController?.pause();
                  Navigator.of(context).pop();
                  _saveVideo();
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getUsernameFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'No username found';
  }

  Future<void> _saveVideo() async {
    if (videoFile != null) {
      setState(() {
        _isUploading = true;
      });

      // Get current user information
      final user = FirebaseAuth.instance.currentUser;
      final username =
          await _getUsernameFromSharedPref(); // Replace with actual field if username is stored differently
      final userId = user?.uid ?? 'Unknown UserID';

      final path = 'shorts/${videoFile!.name}';
      final file = File(videoFile!.path);

      final ref = FirebaseStorage.instance.ref().child(path);
      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});

      final videoUrl = await snapshot.ref.getDownloadURL();

      // Generate and upload thumbnail
      final thumbnailPath = await _generateThumbnail(videoFile!.path);
      final thumbnailFile = File(thumbnailPath);
      final thumbnailRef = FirebaseStorage.instance
          .ref()
          .child('thumbnails/${videoFile!.name}.png');
      final thumbnailUploadTask = thumbnailRef.putFile(thumbnailFile);
      await thumbnailUploadTask.whenComplete(() {});
      final thumbnailUrl = await thumbnailRef.getDownloadURL();

      await _saveVideoDataToDatabase(username, userId, videoUrl, thumbnailUrl,
          _descriptionController.text);

      setState(() {
        _isUploading = false;
        uploadTask = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Video and thumbnail uploaded successfully')),
      );
    }
  }

  Future<String> _generateThumbnail(String videoPath) async {
    final thumbnailPath = await vid_thumb.VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vid_thumb.ImageFormat.PNG,
      maxHeight: 128,
      quality: 25,
    );
    return thumbnailPath!;
  }

  Future<void> _saveVideoDataToDatabase(String username, String userId,
      String videoUrl, String thumbnailUrl, String description) async {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child("shorts");

    final newPostRef = dbRef.push();

    await newPostRef.set({
      'user': username,
      'userId': userId,
      'url': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'dateAdded': dateAdded,
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget buildProgress() {
    return StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
