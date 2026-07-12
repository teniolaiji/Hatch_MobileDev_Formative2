import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/opportunity.dart';
import '../providers/user_providers.dart';
import '../providers/opportunity_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key, this.existing});
  /// When non-null, the form pre-fills with this opportunity and saves as an update.
  final Opportunity? existing;

  @override
  ConsumerState<PostOpportunityScreen> createState() =>
      _PostOpportunityScreenState();
}

class _PostOpportunityScreenState
    extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();

  OpportunityCategory _category = OpportunityCategory.engineering;
  LocationType _location = LocationType.remote;
  final List<String> _skills = [];
  DateTime? _deadline;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _timeCtrl.text = e.timeCommitment;
      _category = e.category;
      _location = e.location;
      _skills.addAll(e.requiredSkills);
      _deadline = e.deadline;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timeCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillCtrl.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() => _skills.add(skill));
    _skillCtrl.clear();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(opportunityRepositoryProvider);
      if (_isEditing) {
        final updated = Opportunity(
          id: widget.existing!.id,
          startupId: widget.existing!.startupId,
          startupName: widget.existing!.startupName,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          requiredSkills: List.from(_skills),
          createdAt: widget.existing!.createdAt,
          location: _location,
          timeCommitment: _timeCtrl.text.trim(),
          deadline: _deadline,
          category: _category,
          startupVerified: widget.existing!.startupVerified,
        );
        await repo.update(updated).timeout(const Duration(seconds: 15));
      } else {
        await repo
            .create(
              Opportunity(
                id: '',
                startupId: user.uid,
                startupName: user.name,
                title: _titleCtrl.text.trim(),
                description: _descCtrl.text.trim(),
                requiredSkills: List.from(_skills),
                createdAt: DateTime.now(),
                location: _location,
                timeCommitment: _timeCtrl.text.trim(),
                deadline: _deadline,
                category: _category,
                startupVerified: user.isVerified,
              ),
            )
            .timeout(const Duration(seconds: 15));
      }
      if (mounted) context.pop();
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Timed out — Firestore rules may be blocking the write. Check your security rules.',
            ),
          ),
        );
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not post role: $e')),
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit role' : 'Post a role')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Title ──────────────────────────────────────────────────────
            const _Label('Role title'),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  hintText: 'e.g. Mobile Developer Intern'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Description ────────────────────────────────────────────────
            const _Label('Description'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  hintText: 'What will this person work on?'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Category ───────────────────────────────────────────────────
            const _Label('Category'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: OpportunityCategory.values.map((cat) {
                final selected = cat == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.navy : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color:
                            selected ? AppColors.navy : AppColors.border,
                      ),
                    ),
                    child: Text(
                      cat.label,
                      style: text.labelMedium?.copyWith(
                        color: selected
                            ? AppColors.cream
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Location ───────────────────────────────────────────────────
            const _Label('Location'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: LocationType.values.map((loc) {
                final selected = loc == _location;
                final label =
                    loc == LocationType.remote ? 'Remote' : 'On-site';
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _location = loc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.navy
                            : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: selected
                              ? AppColors.navy
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        label,
                        style: text.labelMedium?.copyWith(
                          color: selected
                              ? AppColors.cream
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Skills ─────────────────────────────────────────────────────
            const _Label('Required skills'),
            const SizedBox(height: AppSpacing.sm),
            if (_skills.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _skills
                    .map((s) => _SkillChip(
                          skill: s,
                          onRemove: () => setState(() => _skills.remove(s)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        const InputDecoration(hintText: 'e.g. Flutter'),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: _addSkill,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Time commitment ────────────────────────────────────────────
            const _Label('Time commitment'),
            TextFormField(
              controller: _timeCtrl,
              decoration:
                  const InputDecoration(hintText: 'e.g. 10 hrs/week'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Deadline ───────────────────────────────────────────────────
            const _Label('Application deadline (optional)'),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined,
                        size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _deadline == null
                          ? 'Pick a date'
                          : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                      style: text.bodyMedium?.copyWith(
                        color: _deadline == null
                            ? AppColors.textFaint
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Submit ─────────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Post role'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill, required this.onRemove});
  final String skill;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.stone),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child:
                const Icon(Icons.close, size: 14, color: AppColors.stone),
          ),
        ],
      ),
    );
  }
}
