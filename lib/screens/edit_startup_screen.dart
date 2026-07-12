import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class EditStartupScreen extends ConsumerStatefulWidget {
  const EditStartupScreen({super.key});

  @override
  ConsumerState<EditStartupScreen> createState() => _EditStartupScreenState();
}

class _EditStartupScreenState extends ConsumerState<EditStartupScreen> {
  final _pitchCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  String _stage = '';
  bool _seeded = false;
  bool _saving = false;

  static const _stages = ['Idea', 'MVP', 'Growth', 'Scaling'];

  @override
  void dispose() {
    _pitchCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    await ref.read(userRepositoryProvider).updateProfile(uid, {
      'bio': _pitchCtrl.text.trim(),
      'startupStage': _stage,
      'website': _websiteCtrl.text.trim(),
    });
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;

    if (user != null && !_seeded) {
      _pitchCtrl.text = user.bio;
      _websiteCtrl.text = user.website;
      _stage = user.startupStage;
      _seeded = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit startup profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Pitch ──────────────────────────────────────────────────
            Text('Startup pitch', style: text.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'What does your startup do? What problem are you solving?',
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _pitchCtrl,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'We help students find meaningful opportunities…',
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Stage ───────────────────────────────────────────────────
            Text('Stage', style: text.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _stages.map((s) {
                final selected = _stage == s;
                return GestureDetector(
                  onTap: () => setState(() => _stage = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
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
                      s,
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

            const SizedBox(height: AppSpacing.xl),

            // ── Website ─────────────────────────────────────────────────
            Text('Website', style: text.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _websiteCtrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'https://yourstartup.com',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            ElevatedButton(
              onPressed:
                  (_saving || user == null) ? null : () => _save(user.uid),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
