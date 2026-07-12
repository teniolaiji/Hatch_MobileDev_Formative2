import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/status_badge.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class FounderApplicantsScreen extends ConsumerWidget {
  const FounderApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final applicationsAsync = ref.watch(startupApplicationsProvider);
    final pending = ref.watch(startupApplicationsProvider).value
        ?.where((a) => a.status == ApplicationStatus.submitted).length ??
    0;
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: SafeArea(
        child: applicationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text('Could not load applicants.',
                  style: text.bodyMedium)),
          data: (applications) {
            if (applications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No applicants yet.\nApplications to your roles will appear here.',
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
                return InkWell(
                  onTap: () => context.push(
                    Routes.applicantDetail,
                    extra: app,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app.applicantName,
                                  style: text.titleMedium),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                app.opportunityTitle,
                                style: text.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        StatusBadge(status: app.status),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(Icons.chevron_right,
                            size: 18, color: AppColors.stone),
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