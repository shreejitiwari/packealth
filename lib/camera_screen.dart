import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit;

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _useFlash = false;
  XFile? _pickedImage;

  // Text recognition components
  final textRecognizer = mlkit.TextRecognizer();

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
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Take a picture'),
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
          bottom: 16.0,
          left: 0.0,
          right: 0.0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          IconButton(
          icon: Icon(_useFlash ? Icons.flash_on : Icons.flash_off),
          color: Colors.white,
          onPressed: () {
            setState(() {
              _useFlash = !_useFlash;
              _controller.setFlashMode(_useFlash ? FlashMode.torch : FlashMode.off);
            });
          },
        ),
        const Spacer(),
        FloatingActionButton(
        child: const Icon(Icons.camera_alt),
    onPressed: () async {
    try {
    // Take picture
    final image = await _controller.takePicture();
    _
    _handleImageSelection(image);
    } catch (e) {
      // Handle errors
    }
    },
        ),
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

  void _handleImageSelection(XFile? image) async {
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });

      // Extract text from image
      final recognizedText = await _recognizeTextFromImage(image.path);

      // Handle extracted text (e.g., display on screen, navigate)
      print(recognizedText); // Example usage, replace with your desired logic

      // Navigate to display screen (replace with your navigation logic)
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => DisplayImageScreen(imagePath: _pickedImage!.path, extractedText: recognizedText),
      //   ),
      // );
    }
  }

  Future<String> _recognizeTextFromImage(String imagePath) async {
    final inputImage = mlkit.InputImage.fromFilePath(imagePath);
    final recognizedText = await textRecognizer.processImage(inputImage);

    String extractedText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        extractedText += line.text + '\n';
      }
    }
    return extractedText;
  }
}
