import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_matic/models/logo_matic_model.dart';
import 'package:path/path.dart' as path;
import 'package:logo_matic/utils/file_utils.dart';

// Component for selecting a logo image
class LogoSelectionCard extends StatefulWidget {
  const LogoSelectionCard({super.key});

  @override
  State<LogoSelectionCard> createState() => _LogoSelectionCardState();
}

class _LogoSelectionCardState extends State<LogoSelectionCard> with SingleTickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  bool _isDragging = false;
  
  // For interactive logo preview
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScaleAnimation = CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = Provider.of<LogoMaticModel>(context);
    if (model.logoFile != null) {
      _logoAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LogoMaticModel>(context);
    
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
                    Icons.insert_photo_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 2: Select Logo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose a logo to add to your images',
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
            
            // Modern logo selection area with drag & drop
            GestureDetector(
              onTap: () => _selectLogo(context),
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
                  _selectLogo(context);
                },
                onLeave: (_) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return model.logoFile == null
                    ? AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 100,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: _isDragging
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isDragging ? 'Drop logo here' : 'Drag logo here or tap to browse',
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
                                'PNG with transparency recommended',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : _buildLogoPreview(model.logoFile!);
                },
              ),
            ),
            
            // Display logo name and option to change
            if (model.logoFile != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Selected logo: ${path.basename(model.logoFile!.path)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _selectLogo(context),
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
              
              // Default source checkbox
              Row(
                children: [
                  Checkbox(
                    value: model.useGalleryForLogo,
                    onChanged: (value) {
                      if (value != null) {
                        model.toggleUseGalleryForLogo();
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text(
                    'Use gallery as default source',
                    style: TextStyle(fontSize: 13),
                  ),
                  const Tooltip(
                    message: 'When checked, the app will directly open the gallery instead of the file picker',
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPreview(File logoFile) {
    return ScaleTransition(
      scale: _logoScaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.file(
            logoFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.red, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Error loading logo',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Opens the file picker to select a single logo image
  Future<void> _selectLogo(BuildContext context) async {
    final model = Provider.of<LogoMaticModel>(context, listen: false);
    
    final selectedLogo = await FileUtils.pickLogo(context);
    if (selectedLogo != null) {
      model.setLogoFile(selectedLogo);
      _logoAnimationController.reset();
      _logoAnimationController.forward();
    }
  }
} 