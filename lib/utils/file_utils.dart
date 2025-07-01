import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileUtils {
  /// Picks multiple image files
  static Future<List<File>?> pickImages(BuildContext context) async {
    try {
      List<File> files = [];

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        dialogTitle: 'Select Images to Add Logo',
        lockParentWindow: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            final imageFile = File(file.path!);

            try {
              final exists = await imageFile.exists();
              if (exists) {
                files.add(imageFile);
              }
            } catch (e) {
              files.add(imageFile);
            }
          }
        }
      }

      if (files.isNotEmpty) {
        return files;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid images were selected')),
          );
        }
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting images: $e')),
        );
      }
      return null;
    }
  }

  /// Picks a single logo image file
  static Future<File?> pickLogo(BuildContext context) async {
    try {
      File? logoFile;

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        dialogTitle: 'Select Logo Image',
        lockParentWindow: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.path != null) {
        final logoPath = result.files.first.path!;
        logoFile = File(logoPath);
      }

      if (logoFile != null) {
        try {
          final exists = await logoFile.exists();
          if (exists) {
            return logoFile;
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Could not access the selected logo file')),
              );
            }
            return null;
          }
        } catch (fileError) {
          return logoFile;
        }
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting logo: $e')),
        );
      }
      return null;
    }
  }
}
