import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/user_providers.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(opportunity.startupName, style: text.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(opportunity.title, style: text.displayMedium),
            const SizedBox(height: AppSpacing.lg),

            Text('About this role', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(opportunity.description, style: text.bodyLarge),

            if (opportunity.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Skills needed', style: text.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: opportunity.requiredSkills
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _ApplyButton(opportunity: opportunity),
      ),
    );
  }
}

class _ApplyButton extends ConsumerStatefulWidget {
  const _ApplyButton({required this.opportunity});
  final Opportunity opportunity;

  @override
  ConsumerState<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends ConsumerState<_ApplyButton> {
  bool _submitting = false;

  Future<void> _apply() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _submitting = true);
    final repo = ref.read(applicationRepositoryProvider);

    try {
      final already = await repo.hasApplied(
        applicantId: user.uid,
        opportunityId: widget.opportunity.id,
      );
      if (already) {
        if (mounted) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You already applied to this role.')),
          );
        }
        return;
      }

      await repo.submit(Application(
        id: '',
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        startupId: widget.opportunity.startupId,
        applicantId: user.uid,
        applicantName: user.name,
        message: '',
        status: ApplicationStatus.submitted,
        createdAt: DateTime.now(),
      ));

      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted.')),
        );
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not apply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _submitting ? null : _apply,
      child: _submitting
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : const Text('Apply for this role'),
    );
  }
}