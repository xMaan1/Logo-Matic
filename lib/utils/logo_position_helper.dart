import 'package:logo_matic/models/logo_matic_model.dart';

// Utility class with helper methods for logo positions
class LogoPositionHelper {
  // Converts a LogoPosition enum value to a human-readable string
  static String formatLogoPosName(LogoPosition position) {
    switch (position) {
      case LogoPosition.center:
        return 'Center';
      case LogoPosition.topLeft:
        return 'Top Left';
      case LogoPosition.topRight:
        return 'Top Right';
      case LogoPosition.bottomLeft:
        return 'Bottom Left';
      case LogoPosition.bottomRight:
        return 'Bottom Right';
    }
  }
} 