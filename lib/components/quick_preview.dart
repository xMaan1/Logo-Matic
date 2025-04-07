import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_matic/models/logo_matic_model.dart';

class QuickPreview extends StatefulWidget {
  const QuickPreview({super.key});

  @override
  State<QuickPreview> createState() => _QuickPreviewState();
}

class _QuickPreviewState extends State<QuickPreview> with SingleTickerProviderStateMixin {
  Uint8List? _previewImageBytes;
  bool _isLocalLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  LogoPosition? _lastPosition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Faster animation for responsiveness
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _updatePreview();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = Provider.of<LogoMaticModel>(context);
    
    // Only update if we have both images and logo
    if (model.logoFile != null && model.sourceImages != null && model.sourceImages!.isNotEmpty) {
      // If position changed, update immediately
      if (_lastPosition != model.logoPosition) {
        _lastPosition = model.logoPosition;
        _updatePreview();
      }
    }
  }

  Future<void> _updatePreview() async {
    // Only show loading indicator for initial load, not position changes
    if (_previewImageBytes == null) {
      setState(() {
        _isLocalLoading = true;
      });
    }

    final model = Provider.of<LogoMaticModel>(context, listen: false);
    final previewImage = await model.getPreviewImage();
    
    if (mounted) {
      setState(() {
        _previewImageBytes = previewImage;
        _isLocalLoading = false;
      });
      
      // For smoother UI, only animate if this is first load
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LogoMaticModel>(context);
    
    // Hide if we don't have both images and logo
    if (model.sourceImages == null || model.sourceImages!.isEmpty || model.logoFile == null) {
      return const SizedBox.shrink();
    }
    
    // Hide if we already have processed images
    if (model.processedImages != null) {
      return const SizedBox.shrink();
    }
    
    // Keep track of current position for optimization
    _lastPosition = model.logoPosition;
    
    return Card(
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
                    Icons.preview,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'How your logo will appear on the image',
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
            SizedBox(
              height: 200,
              child: Center(
                child: _isLocalLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Generating preview...'),
                        ],
                      )
                    : _previewImageBytes != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              // Show existing image with mild opacity when processing
                              Opacity(
                                opacity: model.isPreviewProcessing ? 0.6 : 1.0,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _previewImageBytes!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Overlay a small indicator when processing
                              if (model.isPreviewProcessing)
                                const SizedBox(
                                  width: 20, 
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          )
                        : const Text('No preview available'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 