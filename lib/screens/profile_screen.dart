import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/components/initials_avatar.dart';
import 'package:hatch/data/auth_repository.dart';
import 'package:hatch/data/user_repository.dart';
import 'package:hatch/models/app_user.dart';
import 'package:hatch/providers/auth_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _skillCtrl = TextEditingController();
  final _interestCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _eduCtrl = TextEditingController();
  bool _initialised = false;
  bool _saving = false;

  @override
  void dispose() {
    _skillCtrl.dispose();
    _interestCtrl.dispose();
    _bioCtrl.dispose();
    _expCtrl.dispose();
    _eduCtrl.dispose();
    super.dispose();
  }

  // Fill the text controllers once from the loaded user.
  void _seed(AppUser user) {
    if (_initialised) return;
    _bioCtrl.text = user.bio;
    _expCtrl.text = user.experience;
    _eduCtrl.text = user.education;
    _initialised = true;
  }

  Future<void> _saveText(AppUser user) async {
    setState(() => _saving = true);
    await ref.read(userRepositoryProvider).updateProfile(user.uid, {
      'bio': _bioCtrl.text.trim(),
      'experience': _expCtrl.text.trim(),
      'education': _eduCtrl.text.trim(),
    });
    ref.invalidate(currentUserProvider);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    }
  }

  Future<void> _addTo(AppUser user, String field, TextEditingController ctrl,
      List<String> current) async {
    final value = ctrl.text.trim();
    if (value.isEmpty || current.contains(value)) return;
    ctrl.clear();
    await ref.read(userRepositoryProvider).updateProfile(user.uid, {
      field: [...current, value],
    });
    ref.invalidate(currentUserProvider);
  }

  Future<void> _removeFrom(AppUser user, String field, String value,
      List<String> current) async {
    await ref.read(userRepositoryProvider).updateProfile(user.uid, {
      field: current.where((v) => v != value).toList(),
    });
    ref.invalidate(currentUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    if (user != null) _seed(user);
    final isStudent = user?.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Identity header
            Center(
              child: Column(
                children: [
                  InitialsAvatar(name: user?.name ?? ''),
                  const SizedBox(height: AppSpacing.md),
                  Text(user?.name ?? 'Your profile',
                      style: text.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(user?.email ?? '', style: text.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.highlight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      isStudent ? 'Student' : 'Founder',
                      style: text.labelSmall
                          ?.copyWith(color: AppColors.highlight),
                    ),
                  ),
                ],
              ),
            ),

            if (isStudent && user != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle('About me'),
              TextField(
                controller: _bioCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'A short introduction about you.'),
              ),

              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('Skills'),
              _ChipEditor(
                items: user.skills,
                controller: _skillCtrl,
                hint: 'e.g. Flutter',
                onAdd: () => _addTo(user, 'skills', _skillCtrl, user.skills),
                onRemove: (s) =>
                    _removeFrom(user, 'skills', s, user.skills),
              ),

              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('Interests'),
              _ChipEditor(
                items: user.interests,
                controller: _interestCtrl,
                hint: 'e.g. Fintech',
                onAdd: () =>
                    _addTo(user, 'interests', _interestCtrl, user.interests),
                onRemove: (s) =>
                    _removeFrom(user, 'interests', s, user.interests),
              ),

              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('Experience'),
              TextField(
                controller: _expCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'Past roles, projects, or volunteering.'),
              ),

              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('Education'),
              TextField(
                controller: _eduCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'e.g. BSc Software Engineering, ALU'),
              ),

              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _saving ? null : () => _saveText(user),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save profile'),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _ChipEditor extends StatelessWidget {
  const _ChipEditor({
    required this.items,
    required this.controller,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> items;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onAdd;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: items
                .map((s) => Chip(label: Text(s), onDeleted: () => onRemove(s)))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: hint),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(onPressed: onAdd, child: const Text('Add')),
          ],
        ),
      ],
    );
  }
}