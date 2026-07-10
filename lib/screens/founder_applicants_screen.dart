import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/components/status_badge.dart';
import 'package:hatch/data/application_repository.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class FounderApplicantsScreen extends ConsumerWidget {
  const FounderApplicantsScreen({super.key});

  Future<void> _setStatus(
    WidgetRef ref,
    BuildContext context,
    String id,
    ApplicationStatus status,
  ) async {
    try {
      await ref
          .read(applicationRepositoryProvider)
          .updateStatus(id, status);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update: $e')),
        );
      }
    }
  }

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
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(app.applicantName,
                                style: text.titleMedium),
                          ),
                          StatusBadge(status: app.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('For: ${app.opportunityTitle}',
                          style: text.bodyMedium),
                      if (app.message.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(app.message, style: text.bodyLarge),
                      ],
                      // Only show actions while still pending.
                      if (app.status == ApplicationStatus.submitted) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _setStatus(ref, context,
                                    app.id, ApplicationStatus.rejected),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _setStatus(ref, context,
                                    app.id, ApplicationStatus.accepted),
                                child: const Text('Accept'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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