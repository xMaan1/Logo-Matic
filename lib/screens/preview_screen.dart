import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_matic/models/logo_matic_model.dart';
import 'package:logo_matic/screens/full_screen_image.dart';

// Screen that displays a grid of processed images
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LogoMaticModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Images'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: model.processedImages == null
          ? const Center(child: Text('No processed images'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: model.processedImages!.length,
              itemBuilder: (context, index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imageBytes: model.processedImages![index],
                            imageIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Image.memory(
                      model.processedImages![index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
} 