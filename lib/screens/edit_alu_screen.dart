import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class EditAluScreen extends ConsumerStatefulWidget {
  const EditAluScreen({super.key});

  @override
  ConsumerState<EditAluScreen> createState() => _EditAluScreenState();
}

class _EditAluScreenState extends ConsumerState<EditAluScreen> {
  String _campus = '';
  String _program = '';
  String _year = '';
  bool _seeded = false;
  bool _saving = false;

  static const _campuses = ['Rwanda', 'Mauritius'];

  static const _programs = [
    'Entrepreneurial Leadership',
    'Global Challenges',
    'Software Engineering',
    'Business Administration',
  ];

  static const _years = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    await ref.read(userRepositoryProvider).updateProfile(uid, {
      'aluCampus': _campus,
      'aluProgram': _program,
      'aluYear': _year,
    });
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;

    if (user != null && !_seeded) {
      _campus = user.aluCampus;
      _program = user.aluProgram;
      _year = user.aluYear;
      _seeded = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ALU context')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Campus ─────────────────────────────────────────────────
            Text('Campus', style: text.titleMedium?.copyWith(color: AppColors.navy)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _campuses
                  .map((c) => _Chip(
                        label: c,
                        selected: _campus == c,
                        onTap: () => setState(() => _campus = c),
                      ))
                  .toList(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Programme ───────────────────────────────────────────────
            Text('Programme', style: text.titleMedium?.copyWith(color: AppColors.navy)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _programs
                  .map((p) => _Chip(
                        label: p,
                        selected: _program == p,
                        onTap: () => setState(() => _program = p),
                      ))
                  .toList(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Year ─────────────────────────────────────────────────
            Text('Year', style: text.titleMedium?.copyWith(color: AppColors.navy)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _years
                  .map((y) => _Chip(
                        label: y,
                        selected: _year == y,
                        onTap: () => setState(() => _year = y),
                      ))
                  .toList(),
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
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
            color: selected ? AppColors.navy : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: text.labelSmall?.copyWith(
            color: selected ? AppColors.cream : AppColors.navy,
          ),
        ),
      ),
    );
  }
}
