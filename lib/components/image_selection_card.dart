import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_matic/models/logo_matic_model.dart';
import 'package:logo_matic/utils/file_utils.dart';

// Component for selecting multiple images
class ImageSelectionCard extends StatefulWidget {
  const ImageSelectionCard({super.key});

  @override
  State<ImageSelectionCard> createState() => _ImageSelectionCardState();
}

class _ImageSelectionCardState extends State<ImageSelectionCard> with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LogoMaticModel>(context);
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 1: Select Images',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Choose one or more images to add your logo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Modern drag & drop area
              GestureDetector(
                onTap: () => _selectImages(context),
                child: DragTarget<String>(
                  onWillAccept: (_) {
                    setState(() {
                      _isDragging = true;
                    });
                    return true;
                  },
                  onAccept: (_) {
                    setState(() {
                      _isDragging = false;
                    });
                    _selectImages(context);
                  },
                  onLeave: (_) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDragging 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isDragging
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: _isDragging ? 2 : 1,
                        ),
                      ),
                      child: model.sourceImages == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_rounded,
                                  size: 40,
                                  color: _isDragging
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isDragging ? 'Drop images here' : 'Drag images here or tap to browse',
                                  style: TextStyle(
                                    color: _isDragging
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!_isDragging) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Supports JPEG, PNG, BMP',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : _buildImageGridPreview(model),
                    );
                  },
                ),
              ),
              
              // Counter and action row
              if (model.sourceImages != null && model.sourceImages!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${model.sourceImages!.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'images selected',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _selectImages(context),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Change'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGridPreview(LogoMaticModel model) {
    final images = model.sourceImages!;
    const maxVisibleImages = 9; // Show at most 9 images, + counter for the rest
    final displayCount = images.length > maxVisibleImages ? maxVisibleImages : images.length;
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        if (index == maxVisibleImages - 1 && images.length > maxVisibleImages) {
          // If this is the last visible cell and we have more images
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  images[index],
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '+${images.length - maxVisibleImages + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 150 + (index * 30)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              images[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  // Opens the file picker to select multiple images
  Future<void> _selectImages(BuildContext context) async {
    final model = Provider.of<LogoMaticModel>(context, listen: false);
    
    final selectedImages = await FileUtils.pickImages(context);
    if (selectedImages != null && selectedImages.isNotEmpty) {
      _controller.reset();
      model.setSourceImages(selectedImages);
      _controller.forward();
    }
  }
} 