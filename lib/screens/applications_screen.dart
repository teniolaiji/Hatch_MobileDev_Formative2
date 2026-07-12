import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/status_badge.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

// ── Grouping ──────────────────────────────────────────────────────────────────

enum _Group { reviewing, pending, decided }

extension _GroupLabel on _Group {
  String get label => switch (this) {
        _Group.reviewing => 'Reviewing',
        _Group.pending => 'Pending',
        _Group.decided => 'Decided',
      };
}

_Group _groupOf(ApplicationStatus status) => switch (status) {
      ApplicationStatus.reviewing => _Group.reviewing,
      ApplicationStatus.submitted => _Group.pending,
      _ => _Group.decided, // accepted + rejected
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: SafeArea(
        child: applicationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Could not load your applications.',
                style: text.bodyMedium),
          ),
          data: (applications) {
            if (applications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'You have not applied to anything yet.\nBrowse Discover to find a role.',
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Build ordered groups — only include groups that have items.
            final grouped = <_Group, List<Application>>{};
            for (final app in applications) {
              grouped.putIfAbsent(_groupOf(app.status), () => []).add(app);
            }
            // Within "decided", accepted comes before rejected.
            grouped[_Group.decided]?.sort((a, b) {
              const order = [
                ApplicationStatus.accepted,
                ApplicationStatus.rejected,
              ];
              return order.indexOf(a.status)
                  .compareTo(order.indexOf(b.status));
            });

            // Flatten into a list of widgets in the display order.
            final items = <Widget>[];
            for (final group in _Group.values) {
              final apps = grouped[group];
              if (apps == null || apps.isEmpty) continue;

              items.add(_SectionHeader(
                label: group.label,
                count: apps.length,
              ));

              for (final app in apps) {
                items.add(_AppCard(app: app));
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              itemBuilder: (_, i) => items[i],
            );
          },
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: text.labelSmall?.copyWith(
              color: AppColors.taupe,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.stone.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              '$count',
              style: text.labelSmall?.copyWith(color: AppColors.taupe),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Application card ──────────────────────────────────────────────────────────

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app});
  final Application app;

  Color get _cardColor => switch (app.status) {
        ApplicationStatus.accepted =>
          AppColors.green.withValues(alpha: 0.08),
        ApplicationStatus.rejected =>
          AppColors.surface,
        _ => AppColors.navy,
      };

  Color get _titleColor => switch (app.status) {
        ApplicationStatus.accepted => AppColors.green,
        ApplicationStatus.rejected => AppColors.textSecondary,
        _ => AppColors.cream,
      };

  Color get _subtitleColor => switch (app.status) {
        ApplicationStatus.rejected => AppColors.stone,
        _ => AppColors.stone,
      };

  Color get _borderColor => switch (app.status) {
        ApplicationStatus.accepted =>
          AppColors.green.withValues(alpha: 0.3),
        ApplicationStatus.rejected => AppColors.border,
        _ => AppColors.border,
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: () =>
            context.push(Routes.myApplicationDetail, extra: app),
        child: Opacity(
          opacity: app.status == ApplicationStatus.rejected ? 0.65 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.opportunityTitle,
                          style: text.titleMedium
                              ?.copyWith(color: _titleColor)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(app.startupName,
                          style: text.bodyMedium
                              ?.copyWith(color: _subtitleColor)),
                    ],
                  ),
                ),
                StatusBadge(status: app.status),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: app.status == ApplicationStatus.accepted
                      ? AppColors.green.withValues(alpha: 0.6)
                      : AppColors.stone,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
