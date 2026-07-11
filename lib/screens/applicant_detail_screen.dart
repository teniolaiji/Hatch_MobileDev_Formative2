import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/initials_avatar.dart';
import 'package:hatch/components/status_badge.dart';
import 'package:hatch/models/app_user.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/models/profile_entry.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class ApplicantDetailScreen extends ConsumerWidget {
  const ApplicantDetailScreen({super.key, required this.application});
  final Application application;

  Future<void> _setStatus(
      WidgetRef ref, BuildContext context, ApplicationStatus status) async {
    try {
      await ref
          .read(applicationRepositoryProvider)
          .updateStatus(application.id, status);
      if (context.mounted) context.pop();
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
    final applicantAsync = ref.watch(userByIdProvider(application.applicantId));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant')),
      body: SafeArea(
        child: applicantAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text('Could not load this applicant.',
                  style: text.bodyMedium)),
          data: (user) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Identity
              Center(
                child: Column(
                  children: [
                    InitialsAvatar(name: user?.name ?? application.applicantName),
                    const SizedBox(height: AppSpacing.md),
                    Text(user?.name ?? application.applicantName,
                        style: text.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    StatusBadge(status: application.status),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Their message for this role
              _Block(
                title: 'Applied for',
                child: Text(application.opportunityTitle, style: text.bodyLarge),
              ),
              if (application.message.isNotEmpty)
                _Block(
                  title: 'Their message',
                  child: Text(application.message, style: text.bodyLarge),
                ),

              // Full profile
              if (user != null) ...[
                if (user.bio.isNotEmpty)
                  _Block(title: 'About', child: Text(user.bio, style: text.bodyLarge)),
                if (user.skills.isNotEmpty)
                  _Block(title: 'Skills', child: _Chips(items: user.skills)),
                if (user.interests.isNotEmpty)
                  _Block(title: 'Interests', child: _Chips(items: user.interests)),
                if (user.experience.isNotEmpty)
                  _Block(title: 'Experience', child: _Entries(entries: user.experience)),
                if (user.education.isNotEmpty)
                  _Block(title: 'Education', child: _Entries(entries: user.education)),
              ],
            ],
          ),
        ),
      ),
      // Actions only while still pending.
      bottomNavigationBar: application.status == ApplicationStatus.submitted
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _setStatus(ref, context, ApplicationStatus.rejected),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _setStatus(ref, context, ApplicationStatus.accepted),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: items.map((s) => Chip(label: Text(s))).toList(),
      );
}

class _Entries extends StatelessWidget {
  const _Entries({required this.entries});
  final List<ProfileEntry> entries;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: text.titleMedium),
                    Text('${e.place}  ·  ${e.year}', style: text.bodyMedium),
                  ],
                ),
              ))
          .toList(),
    );
  }
}