import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/components/verified_badge.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/models/app_user.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/user_providers.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  Future<void> _toggleSave(WidgetRef ref) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final current = user.savedOpportunities;
    final updated = current.contains(opportunity.id)
        ? current.where((id) => id != opportunity.id).toList()
        : [...current, opportunity.id];
    await ref
        .read(userRepositoryProvider)
        .updateProfile(user.uid, {'savedOpportunities': updated});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final isStudent = user?.role == UserRole.student;
    final isSaved =
        ref.watch(savedOpportunityIdsProvider).contains(opportunity.id);
    final userSkillSet =
        (user?.skills ?? []).map((s) => s.toLowerCase()).toSet();

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isStudent)
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? AppColors.navy : AppColors.stone,
              ),
              tooltip: isSaved ? 'Remove bookmark' : 'Save role',
              onPressed: () => _toggleSave(ref),
            ),
        ],
      ),
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
              _SkillsSection(
                skills: opportunity.requiredSkills,
                userSkillSet: isStudent ? userSkillSet : null,
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

// ── Skill gap section ─────────────────────────────────────────────────────────

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({
    required this.skills,
    required this.userSkillSet,
  });

  /// Required skills for this opportunity.
  final List<String> skills;

  /// The current student's skills (lowercased). Null means non-student viewer —
  /// show all chips in the default navy style with no gap hints.
  final Set<String>? userSkillSet;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final knownSkills = userSkillSet;

    final matched = knownSkills == null
        ? 0
        : skills.where((s) => knownSkills.contains(s.toLowerCase())).length;
    final total = skills.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: label + match summary (students only)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Skills needed', style: text.titleMedium),
            if (knownSkills != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: matched == total
                      ? AppColors.green.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: matched == total
                        ? AppColors.green.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  '$matched / $total matched',
                  style: text.labelSmall?.copyWith(
                    color: matched == total
                        ? AppColors.green
                        : AppColors.taupe,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Skill chips
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: skills.map((s) {
            final have = knownSkills?.contains(s.toLowerCase()) ?? false;
            // When no userSkillSet (non-student), render default navy chip
            if (knownSkills == null) {
              return _SkillChip(label: s, state: _ChipState.neutral);
            }
            return _SkillChip(
              label: s,
              state: have ? _ChipState.matched : _ChipState.missing,
            );
          }).toList(),
        ),

        // Gap hint (students only, when there are missing skills)
        if (knownSkills != null && matched < total) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 14, color: AppColors.taupe),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Skills you don\'t have yet are shown in outline. '
                  'Consider adding them to your profile as you learn.',
                  style: text.bodySmall?.copyWith(color: AppColors.taupe),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

enum _ChipState { matched, missing, neutral }

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, required this.state});
  final String label;
  final _ChipState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final (bg, border, fg, icon) = switch (state) {
      _ChipState.matched => (
          AppColors.green.withValues(alpha: 0.12),
          AppColors.green.withValues(alpha: 0.4),
          AppColors.green,
          Icons.check_rounded,
        ),
      _ChipState.missing => (
          Colors.transparent,
          AppColors.border,
          AppColors.stone,
          null,
        ),
      _ChipState.neutral => (
          AppColors.navy,
          Colors.transparent,
          AppColors.stone,
          null,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: text.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
