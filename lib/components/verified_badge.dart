import 'package:flutter/material.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

/// A small "Verified" badge displayed next to a startup name.
/// Shown only when [show] is true — callers can pass `opportunity.startupVerified`
/// directly without needing an if/else at the call site.
/// Tapping it shows a bottom sheet explaining what verification means.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.show = true, this.onDark = false});

  /// Whether to render at all. When false, returns SizedBox.shrink().
  final bool show;

  /// Use true when the badge sits on a dark/navy background (e.g. TopMatchCard).
  final bool onDark;

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.green,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Verified Startup',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This startup has been reviewed and confirmed by the Hatch team. '
              'Verified startups are active ALU ventures whose founders have been '
              'authenticated through the programme.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    final color = onDark ? AppColors.ochre : AppColors.green;

    return GestureDetector(
      onTap: () => _showInfo(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.verified_rounded, size: 14, color: color),
        ],
      ),
    );
  }
}
