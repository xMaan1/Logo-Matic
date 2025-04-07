import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_matic/models/logo_matic_model.dart';

// Component for the process button
class ProcessButton extends StatelessWidget {
  const ProcessButton({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LogoMaticModel>(context);
    final bool canProcess = model.sourceImages != null && 
                           model.logoFile != null && 
                           !model.isProcessing;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: canProcess ? () async {
          await model.processImages();
          if (context.mounted) {
            model.showProcessingSuccess(context);
          }
        } : null,
        icon: model.isProcessing
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.auto_fix_high),
        label: Text(
          model.isProcessing ? 'Processing...' : 'Apply Logo to Images',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Component for the save button (used if we need a standalone save button)
class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LogoMaticModel>(context);
    final bool hasProcessedImages = model.processedImages != null;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: hasProcessedImages ? () => model.saveProcessedImages(context) : null,
        icon: const Icon(Icons.save_alt),
        label: const Text(
          'Save All Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
} 