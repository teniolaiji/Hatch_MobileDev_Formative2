import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/components/verified_badge.dart';
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(opportunity.startupName, style: text.labelLarge),
                VerifiedBadge(show: opportunity.startupVerified),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(opportunity.title, style: text.displayMedium),
            const SizedBox(height: AppSpacing.lg),

            Text('About this role', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(opportunity.description, style: text.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            Text('Details', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: opportunity.location == LocationType.remote
                        ? Icons.language
                        : Icons.location_on_outlined,
                    label: 'Location',
                    value: opportunity.location == LocationType.remote
                        ? 'Remote'
                        : 'On-site',
                  ),
                  if (opportunity.timeCommitment.isNotEmpty)
                    _InfoRow(
                      icon: Icons.schedule,
                      label: 'Time',
                      value: opportunity.timeCommitment,
                    ),
                  if (opportunity.deadline != null)
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Apply by',
                      value:
                          '${opportunity.deadline!.day}/${opportunity.deadline!.month}/${opportunity.deadline!.year}',
                    ),
                ],
              ),
            ),

            if (opportunity.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Skills needed', style: text.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: opportunity.requiredSkills
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Text(
                            s,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.stone),
                          ),
                        ))
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

    final repo = ref.read(applicationRepositoryProvider);

    final already = await repo.hasApplied(
      applicantId: user.uid,
      opportunityId: widget.opportunity.id,
    );
    if (already) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already applied to this role.')),
        );
      }
      return;
    }

    final message = await _promptForMessage();
    if (message == null) return; // user cancelled

    setState(() => _submitting = true);
    try {
      await repo.submit(
        Application(
          id: '',
          opportunityId: widget.opportunity.id,
          opportunityTitle: widget.opportunity.title,
          startupId: widget.opportunity.startupId,
          startupName: widget.opportunity.startupName,
          applicantId: user.uid,
          applicantName: user.name,
          message: message,
          status: ApplicationStatus.submitted,
          createdAt: DateTime.now(),
        ),
      );
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Application submitted.')));
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not apply: $e')));
      }
    }
  }

  //Opens a dialog for the applicant's message.
  Future<String?> _promptForMessage() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why are you a good fit?'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Briefly explain why this role suits you.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Text('$label  ', style: text.bodyMedium),
          Expanded(
            child: Text(
              value,
              style: text.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
