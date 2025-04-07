import 'dart:typed_data';
import 'package:flutter/material.dart';

// Screen that displays a single image in full-screen with zooming capabilities
class FullScreenImage extends StatelessWidget {
  final Uint8List imageBytes;
  final int imageIndex;
  
  const FullScreenImage({
    super.key,
    required this.imageBytes,
    required this.imageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image ${imageIndex + 1}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.memory(
              imageBytes,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
} 