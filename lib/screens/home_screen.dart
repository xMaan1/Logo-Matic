import 'package:flutter/material.dart';
import 'package:logo_matic/components/image_selection_card.dart';
import 'package:logo_matic/components/logo_selection_card.dart';
import 'package:logo_matic/components/logo_position_card.dart';
import 'package:logo_matic/components/action_buttons.dart';
import 'package:logo_matic/components/live_preview_card.dart';
import 'package:logo_matic/components/quick_preview.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// The main home screen of the application
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Hero(
                  tag: 'app_title',
                  child: const Text(
                    'Logo Matic',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 0.8,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Add your logo to multiple images in seconds',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: AnimationLimiter(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: const [
                        // Step 1: Select images
                        ImageSelectionCard(),
                        SizedBox(height: 16),
                        // Step 2: Select logo
                        LogoSelectionCard(),
                        SizedBox(height: 16),
                        // Step 3: Choose logo position
                        LogoPositionCard(),
                        SizedBox(height: 16),
                        // Quick live preview (before processing)
                        QuickPreview(),
                        SizedBox(height: 24),
                        // Live preview of processed images
                        LivePreviewCard(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 