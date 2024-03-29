import 'dart:async';
import 'dart:io';


import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}


class MyapppState extends ChangeNotifier{
  var ingredients = <String>[];
}

class MyApp extends StatelessWidget{
  const MyApp({super.key,});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Packealth',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<CameraDescription> getCamera() async {
    final cameras = await availableCameras();
    return cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    // ... other code

    return Scaffold( // Changed widget to Scaffold
      appBar: AppBar(
        title: const Text("Packealth"),
        //centerTitle: true,
      ),
      body: Center(
        child: IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: () async {
            final camera = await getCamera();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakePictureScreen(camera: camera),
              ),
            );
          },
          iconSize: 70,
        ),
      ),
    );
  }
}


class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({super.key, required this.camera});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _useFlash = false;
  XFile? _pickedImage; // Stores the path of the selected image (camera or gallery)

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
      ),
      body: Stack(
        children: [
          // Camera preview
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    CameraPreview(_controller),
                    // Display chosen image (if available)
                    if (_pickedImage != null)
                      Center(
                        child: Image.file(File(_pickedImage!.path)), // Display image
                      ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          // Bottom row for buttons
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flash button
                IconButton(
                  icon: Icon(
                    _useFlash ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _useFlash = !_useFlash;
                      _controller.setFlashMode(_useFlash ? FlashMode.torch : FlashMode.off);
                      // Update flash mode in the controller
                    });
                  },
                ),
                // Camera button (centered)
                const Spacer(),
                FloatingActionButton(
                  child: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    try {
                      // Take picture
                      final image = await _controller.takePicture();
                      _handleImageSelection(image);
                    } catch (e) {
                      // Handle errors
                    }
                  },
                ),

                // Gallery button
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  color: Colors.white,
                  onPressed: () async {
                    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                    _handleImageSelection(pickedImage);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleImageSelection(XFile? image) {
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayImageScreen(imagePath: _pickedImage!.path),
        ),
      ).then((_) => setState(() { // Reset _pickedImage after returning from DisplayImageScreen
        _pickedImage = null;
      }));
    }
  }
}

class DisplayImageScreen extends StatelessWidget {
  final String imagePath;

  const DisplayImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image'),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
