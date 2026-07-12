import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/status_badge.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

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
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: applications.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final app = applications[i];
                return GestureDetector(
                  onTap: () => context.push(Routes.myApplicationDetail, extra: app),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app.opportunityTitle,
                                  style: text.titleMedium
                                      ?.copyWith(color: AppColors.cream)),
                              const SizedBox(height: AppSpacing.xs),
                              Text(app.startupName,
                                  style: text.bodyMedium
                                      ?.copyWith(color: AppColors.stone)),
                            ],
                          ),
                        ),
                        StatusBadge(status: app.status),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.stone, size: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}