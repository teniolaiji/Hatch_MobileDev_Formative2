import 'package:flutter/material.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

/// A small "Verified" badge displayed next to a startup name.
/// Shown only when [show] is true — callers can pass `opportunity.startupVerified`
/// directly without needing an if/else at the call site.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.show = true, this.onDark = false});

  /// Whether to render at all. When false, returns SizedBox.shrink().
  final bool show;

  /// Use true when the badge sits on a dark/navy background (e.g. TopMatchCard).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    final color = onDark ? AppColors.ochre : AppColors.green;

    return Tooltip(
      message: 'Verified startup',
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
