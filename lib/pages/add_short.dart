import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyAddShort extends StatefulWidget {
  const MyAddShort({super.key});

  @override
  State<MyAddShort> createState() => _MyAddShortState();
}

class _MyAddShortState extends State<MyAddShort> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  VideoPlayerController? videoPlayerController;
  bool isFrontCamera = true;
  bool isRecording = false;
  XFile? videoFile;
  Duration recordingDuration = Duration.zero;
  Timer? timer;
  UploadTask? uploadTask;
  bool _isUploading = false;

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
            CameraPreview(cameraController!),
            Positioned(
              top: 20,
              left: MediaQuery.of(context).size.width / 2 - 40,
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
              left: 20,
              child: IconButton(
                onPressed:
                    isRecording ? _stopVideoRecording : _startVideoRecording,
                iconSize: 40,
                icon: Icon(
                  isRecording ? Icons.stop : Icons.videocam,
                  color: Colors.red,
                ),
              ),
            ),
            isRecording
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
    final _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(
          isFrontCamera ? cameras.last : cameras.first,
          ResolutionPreset.high,
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
        timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
          setState(() {
            recordingDuration += Duration(seconds: 1);
          });
          if (recordingDuration >= Duration(minutes: 1)) {
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
        return AlertDialog(
          title: const Text("Review Video"),
          content: videoPlayerController != null &&
                  videoPlayerController!.value.isInitialized
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: videoPlayerController!.value.aspectRatio,
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
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future _saveVideo() async {
    if (videoFile != null) {
      setState(() {
        _isUploading = true;
      });
      final path = 'shorts/${videoFile!.name}';
      final file = File(videoFile!.path);

      final ref = FirebaseStorage.instance.ref().child(path);
      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();
      print("Video saved at: ${videoFile!.path}");
      print("Download at at: ${urlDownload}");

      setState(() {
        uploadTask = null;
        _isUploading = false;
      });
    }
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;

            if (progress == 1.0) {
              return const SizedBox(height: 50);
            } else {
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              );
            }
          } else {
            return const SizedBox(height: 50);
          }
        },
      );
}
