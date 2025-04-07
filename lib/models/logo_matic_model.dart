import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' as path;

// Enum defining possible logo positions on images
enum LogoPosition {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// Model class that manages the state and business logic of the app
class LogoMaticModel extends ChangeNotifier {
  List<File>? _sourceImages;
  File? _logoFile;
  List<Uint8List>? _processedImages;
  LogoPosition _logoPosition = LogoPosition.bottomRight;
  bool _isProcessing = false;
  
  // Add caching for image processing
  img.Image? _cachedSourceImage;
  img.Image? _cachedLogoImage;
  bool _isPreviewProcessing = false;
  
  // Default source selection preferences
  bool _useGalleryForImages = false;
  bool _useGalleryForLogo = false;

  // Getters
  List<File>? get sourceImages => _sourceImages;
  File? get logoFile => _logoFile;
  List<Uint8List>? get processedImages => _processedImages;
  LogoPosition get logoPosition => _logoPosition;
  bool get isProcessing => _isProcessing;
  bool get isPreviewProcessing => _isPreviewProcessing;
  bool get useGalleryForImages => _useGalleryForImages;
  bool get useGalleryForLogo => _useGalleryForLogo;

  // Toggle default source for images
  void toggleUseGalleryForImages() {
    _useGalleryForImages = !_useGalleryForImages;
    notifyListeners();
  }

  // Toggle default source for logo
  void toggleUseGalleryForLogo() {
    _useGalleryForLogo = !_useGalleryForLogo;
    notifyListeners();
  }

  // Sets the source images and clears processed images
  void setSourceImages(List<File> images) {
    debugPrint('Setting source images: ${images.length}');
    _sourceImages = images;
    _processedImages = null;
    _cachedSourceImage = null; // Clear cache when source changes
    notifyListeners();
    debugPrint('Source images set: ${_sourceImages?.length}');
    
    // Auto process if we already have a logo
    if (_logoFile != null && !_isProcessing) {
      processImages();
    }
  }

  // Sets the logo file and clears processed images
  void setLogoFile(File? logo) {
    debugPrint('Setting logo file: ${logo?.path}');
    _logoFile = logo;
    _processedImages = null;
    _cachedLogoImage = null; // Clear cache when logo changes
    notifyListeners();
    debugPrint('Logo file set: ${_logoFile?.path}');
    
    // Auto process if we have source images
    if (_sourceImages != null && _sourceImages!.isNotEmpty && logo != null && !_isProcessing) {
      processImages();
    }
  }

  // Sets the logo position and clears processed images
  void setLogoPosition(LogoPosition position) {
    if (_logoPosition == position) return; // Skip if position hasn't changed
    
    _logoPosition = position;
    // Don't clear processed images here, just update them
    notifyListeners();
    
    // Auto process images if we have source images and logo
    if (_sourceImages != null && _logoFile != null && !_isProcessing) {
      // We still want to process all images, but prioritize preview responsiveness
      processImages();
    }
  }

  // Shows a success message after processing
  void showProcessingSuccess(BuildContext context) {
    if (_processedImages != null && _processedImages!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Images processed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Shows a success message after saving
  void showSavingSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All images saved to gallery successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Processes all images by adding the logo to each one
  Future<void> processImages() async {
    if (_sourceImages == null || _logoFile == null) return;
    
    _isProcessing = true;
    _processedImages = null;
    notifyListeners();

    try {
      // Use compute to run the image processing in a separate isolate for better performance
      final logoBytes = await _logoFile!.readAsBytes();
      final logoImage = img.decodeImage(logoBytes);
      
      if (logoImage == null) {
        throw Exception('Could not decode logo image');
      }
      
      // Get logo dimensions
      final logoWidth = logoImage.width;
      final logoHeight = logoImage.height;
      
      final List<Uint8List> results = [];
      
      // Process each image
      for (var imageFile in _sourceImages!) {
        final sourceBytes = await imageFile.readAsBytes();
        final sourceImage = img.decodeImage(sourceBytes);
        
        if (sourceImage == null) continue;
        
        // Use compute for better performance
        final processedBytes = await compute(_processImage, {
          'sourceImage': sourceImage,
          'logoImage': logoImage,
          'logoWidth': logoWidth,
          'logoHeight': logoHeight,
          'logoPosition': _logoPosition.index,
        });
        
        results.add(Uint8List.fromList(processedBytes));
      }
      
      _processedImages = results;
    } catch (e) {
      debugPrint('Error processing images: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  // Static method that can be used with compute function
  static List<int> _processImage(Map<String, dynamic> params) {
    final sourceImage = params['sourceImage'] as img.Image;
    final logoImage = params['logoImage'] as img.Image;
    final logoWidth = params['logoWidth'] as int;
    final logoHeight = params['logoHeight'] as int;
    final logoPosition = LogoPosition.values[params['logoPosition'] as int];
    
    // Calculate a reasonable logo size (20% of the shortest dimension)
    final targetLogoWidth = (sourceImage.width * 0.2).round();
    final targetLogoHeight = (logoHeight * targetLogoWidth / logoWidth).round();
    
    // Resize the logo proportionally
    final resizedLogo = img.copyResize(
      logoImage,
      width: targetLogoWidth,
      height: targetLogoHeight,
    );
    
    // Create a copy of the source image
    final outputImage = img.copyResize(sourceImage, width: sourceImage.width, height: sourceImage.height);
    
    // Calculate position for the logo based on the selected position
    int x = 0, y = 0;
    switch (logoPosition) {
      case LogoPosition.center:
        x = (sourceImage.width - resizedLogo.width) ~/ 2;
        y = (sourceImage.height - resizedLogo.height) ~/ 2;
        break;
      case LogoPosition.topLeft:
        x = 10;
        y = 10;
        break;
      case LogoPosition.topRight:
        x = sourceImage.width - resizedLogo.width - 10;
        y = 10;
        break;
      case LogoPosition.bottomLeft:
        x = 10;
        y = sourceImage.height - resizedLogo.height - 10;
        break;
      case LogoPosition.bottomRight:
        x = sourceImage.width - resizedLogo.width - 10;
        y = sourceImage.height - resizedLogo.height - 10;
        break;
    }
    
    // Composite the logo onto the image at the calculated position
    img.compositeImage(outputImage, resizedLogo, dstX: x, dstY: y);
    
    // Convert the processed image to PNG format
    return img.encodePng(outputImage);
  }

  // Saves all processed images to the device gallery
  Future<void> saveProcessedImages(BuildContext context) async {
    if (_processedImages == null) return;
    
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      for (int i = 0; i < _processedImages!.length; i++) {
        final bytes = _processedImages![i];
        final originalFileName = path.basename(_sourceImages![i].path);
        final savePath = '${tempDir.path}/logo_matic_${timestamp}_$originalFileName';
        
        final file = File(savePath);
        await file.writeAsBytes(bytes);
        
        await GallerySaver.saveImage(file.path);
      }
      
      if (context.mounted) {
        showSavingSuccess(context);
      }
    } catch (e) {
      debugPrint('Error saving images: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving images: $e')),
        );
      }
    }
  }

  // Gets a single preview image (first one) for quick preview - optimized version
  Future<Uint8List?> getPreviewImage() async {
    if (_sourceImages == null || _sourceImages!.isEmpty || _logoFile == null) {
      return null;
    }
    
    _isPreviewProcessing = true;
    
    try {
      // Cache logo image for better performance
      if (_cachedLogoImage == null) {
        final logoBytes = await _logoFile!.readAsBytes();
        _cachedLogoImage = img.decodeImage(logoBytes);
        if (_cachedLogoImage == null) return null;
      }
      
      // Cache source image for better performance
      if (_cachedSourceImage == null) {
        final sourceBytes = await _sourceImages!.first.readAsBytes();
        _cachedSourceImage = img.decodeImage(sourceBytes);
        if (_cachedSourceImage == null) return null;
      }
      
      // Use previewProcessImage which is a lighter version of the image processor
      final processedBytes = await compute(previewProcessImage, {
        'sourceImage': _cachedSourceImage!,
        'logoImage': _cachedLogoImage!,
        'logoWidth': _cachedLogoImage!.width,
        'logoHeight': _cachedLogoImage!.height,
        'logoPosition': _logoPosition.index,
      });
      
      return Uint8List.fromList(processedBytes);
    } catch (e) {
      debugPrint('Error generating preview: $e');
      return null;
    } finally {
      _isPreviewProcessing = false;
    }
  }
  
  // Lightweight preview processor - optimized for performance
  static List<int> previewProcessImage(Map<String, dynamic> params) {
    final sourceImage = params['sourceImage'] as img.Image;
    final logoImage = params['logoImage'] as img.Image;
    final logoWidth = params['logoWidth'] as int;
    final logoHeight = params['logoHeight'] as int;
    final logoPosition = LogoPosition.values[params['logoPosition'] as int];
    
    // For preview, use a smaller source image to improve performance
    final previewWidth = 600; // Reasonable size for preview
    final aspectRatio = sourceImage.width / sourceImage.height;
    final previewHeight = (previewWidth / aspectRatio).round();
    
    // Create smaller source image for preview
    final smallerSource = img.copyResize(
      sourceImage,
      width: previewWidth,
      height: previewHeight,
      interpolation: img.Interpolation.average,
    );
    
    // Calculate a reasonable logo size (20% of the shortest dimension)
    final targetLogoWidth = (smallerSource.width * 0.2).round();
    final targetLogoHeight = (logoHeight * targetLogoWidth / logoWidth).round();
    
    // Resize the logo proportionally
    final resizedLogo = img.copyResize(
      logoImage,
      width: targetLogoWidth,
      height: targetLogoHeight,
      interpolation: img.Interpolation.average,
    );
    
    // Create a copy of the source image
    final outputImage = smallerSource; // No need to copy for preview
    
    // Calculate position for the logo based on the selected position
    int x = 0, y = 0;
    switch (logoPosition) {
      case LogoPosition.center:
        x = (smallerSource.width - resizedLogo.width) ~/ 2;
        y = (smallerSource.height - resizedLogo.height) ~/ 2;
        break;
      case LogoPosition.topLeft:
        x = 10;
        y = 10;
        break;
      case LogoPosition.topRight:
        x = smallerSource.width - resizedLogo.width - 10;
        y = 10;
        break;
      case LogoPosition.bottomLeft:
        x = 10;
        y = smallerSource.height - resizedLogo.height - 10;
        break;
      case LogoPosition.bottomRight:
        x = smallerSource.width - resizedLogo.width - 10;
        y = smallerSource.height - resizedLogo.height - 10;
        break;
    }
    
    // Composite the logo onto the image at the calculated position
    img.compositeImage(outputImage, resizedLogo, dstX: x, dstY: y);
    
    // Use a lower quality for preview to improve performance
    return img.encodePng(outputImage, level: 6); // Lower compression level = faster
  }
} 