import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileUtils {
  static final _imagePicker = ImagePicker();

  /// Picks multiple image files with enhanced error handling and logging
  static Future<List<File>?> pickImages(BuildContext context) async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return null;
      
      List<File> files = [];
      
      if (source == ImageSource.gallery) {
        // Use gallery picker
        final images = await _imagePicker.pickMultiImage();
        
        if (images.isNotEmpty) {
          files = images.map((xFile) => File(xFile.path)).toList();
        }
      } else {
        // Use file picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
          onFileLoading: (FilePickerStatus status) => debugPrint('Status: $status'),
          dialogTitle: 'Select Images to Add Logo',
          lockParentWindow: true,
          withData: false,
          withReadStream: false,
        );
        
        debugPrint('Image picker result: $result');
        
        if (result != null && result.files.isNotEmpty) {
          for (final file in result.files) {
            if (file.path != null) {
              debugPrint('Selected image path: ${file.path}');
              final imageFile = File(file.path!);
              
              try {
                final exists = await imageFile.exists();
                if (exists) {
                  files.add(imageFile);
                } else {
                  debugPrint('File does not exist: ${file.path}');
                }
              } catch (e) {
                debugPrint('Error checking file existence: $e');
                // Still add the file despite the error
                files.add(imageFile);
              }
            }
          }
        }
      }
      
      if (files.isNotEmpty) {
        debugPrint('Returning ${files.length} valid image files');
        return files;
      } else {
        debugPrint('No valid files were selected');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid images were selected')),
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting images: $e')),
        );
      }
      return null;
    }
  }

  /// Picks a single logo image file with enhanced error handling and logging
  static Future<File?> pickLogo(BuildContext context) async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return null;
      
      File? logoFile;
      
      if (source == ImageSource.gallery) {
        // Use gallery picker
        final image = await _imagePicker.pickImage(source: ImageSource.gallery);
        
        if (image != null) {
          logoFile = File(image.path);
        }
      } else {
        // Use file picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          onFileLoading: (FilePickerStatus status) => debugPrint('Status: $status'),
          dialogTitle: 'Select Logo Image',
          lockParentWindow: true,
          withData: false,
          withReadStream: false,
        );
        
        debugPrint('Logo picker result: $result');
        
        if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
          final logoPath = result.files.first.path!;
          debugPrint('Selected logo path: $logoPath');
          
          logoFile = File(logoPath);
        }
      }
      
      if (logoFile != null) {
        try {
          final exists = await logoFile.exists();
          debugPrint('Logo file exists: $exists');
          
          if (exists) {
            return logoFile;
          } else {
            debugPrint('Logo file does not exist at path: ${logoFile.path}');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not access the selected logo file')),
              );
            }
            return null;
          }
        } catch (fileError) {
          debugPrint('Error checking logo file: $fileError');
          // Try to return the logo anyway
          return logoFile;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error selecting logo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting logo: $e')),
        );
      }
      return null;
    }
  }
  
  /// Shows a dialog to choose between gallery and file picker
  static Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Source'),
          content: const Text('Choose where to select your image from'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('File Picker'),
            ),
          ],
        );
      }
    );
  }
} 