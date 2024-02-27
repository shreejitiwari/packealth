import 'package:flutter/material.dart';

class DisplayImageScreen extends StatelessWidget {
  final String imagePath;
  final String extractedText;

  const DisplayImageScreen({super.key, required this.imagePath, required this.extractedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: Stack(
        children: [
          // Display the captured image
          Center(
            child: Image.file(File(imagePath)),
          ),
          // Display extracted text below the image
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Text(
              extractedText,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
