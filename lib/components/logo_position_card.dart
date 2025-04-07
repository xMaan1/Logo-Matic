import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_matic/models/logo_matic_model.dart';
import 'package:logo_matic/utils/logo_position_helper.dart';

// Component for selecting the position of the logo on images
class LogoPositionCard extends StatefulWidget {
  const LogoPositionCard({super.key});
  
  @override
  State<LogoPositionCard> createState() => _LogoPositionCardState();
}

class _LogoPositionCardState extends State<LogoPositionCard> {
  // Use a local position to avoid UI lags
  LogoPosition? _selectedPosition;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = Provider.of<LogoMaticModel>(context);
    // Initialize selected position from model
    if (_selectedPosition == null) {
      _selectedPosition = model.logoPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LogoMaticModel>(context);
    _selectedPosition = model.logoPosition;
    
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
                    Icons.format_shapes_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 3: Choose Logo Position',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Select where to place the logo on your images',
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
            // Replace dropdown with more responsive position selector
            _buildPositionSelector(context, model),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPositionSelector(BuildContext context, LogoMaticModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Logo Position: ${LogoPositionHelper.formatLogoPosName(model.logoPosition)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPositionButton(
                    context, 
                    LogoPosition.topLeft,
                    Icons.north_west,
                    model
                  ),
                  _buildPositionButton(
                    context, 
                    LogoPosition.topRight,
                    Icons.north_east,
                    model
                  ),
                  _buildPositionButton(
                    context, 
                    LogoPosition.center,
                    Icons.crop_din,
                    model
                  ),
                  _buildPositionButton(
                    context, 
                    LogoPosition.bottomLeft,
                    Icons.south_west,
                    model
                  ),
                  _buildPositionButton(
                    context, 
                    LogoPosition.bottomRight,
                    Icons.south_east,
                    model
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPositionButton(
    BuildContext context, 
    LogoPosition position, 
    IconData icon,
    LogoMaticModel model
  ) {
    final isSelected = model.logoPosition == position;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _selectedPosition = position;
          });
          model.setLogoPosition(position);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
} 