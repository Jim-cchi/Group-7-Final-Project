import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class MyAddShort extends StatefulWidget {
  const MyAddShort({super.key});

  @override
  State<MyAddShort> createState() => _MyAddShortState();
}

class _MyAddShortState extends State<MyAddShort> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool isFrontCamera = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
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
              bottom: 20,
              right: 156,
              child: IconButton(
                onPressed: () async {
                  XFile picture = await cameraController!.takePicture();
                  Gal.putImage(picture.path);
                },
                iconSize: 20,
                icon: const Icon(
                  Icons.camera,
                  color: Colors.red,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                onPressed: () async {
                  setState(() {
                    isFrontCamera = !isFrontCamera;
                    _setupCameraController();
                  });
                },
                iconSize: 20,
                icon: const Icon(
                  Icons.flip_camera_android,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(
        () {
          cameras = _cameras;
          cameraController = CameraController(
            isFrontCamera ? cameras.last : cameras.first,
            ResolutionPreset.high,
          );
        },
      );
      cameraController?.initialize().then(
        (_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        },
      ).catchError(
        (Object e) {
          print(e);
        },
      );
    }
  }
}
