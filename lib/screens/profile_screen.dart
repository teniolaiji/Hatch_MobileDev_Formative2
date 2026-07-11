import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _skillCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSkill(AppUser user) async {
    final skill = _skillCtrl.text.trim();
    if (skill.isEmpty || user.skills.contains(skill)) return;
    final updated = [...user.skills, skill];
    _skillCtrl.clear();
    await _save(user.uid, updated);
  }

  Future<void> _removeSkill(AppUser user, String skill) async {
    final updated = user.skills.where((s) => s != skill).toList();
    await _save(user.uid, updated);
  }

  Future<void> _save(String uid, List<String> skills) async {
    await ref.read(userRepositoryProvider).updateSkills(uid, skills);
    ref.invalidate(currentUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(user?.name ?? 'Your profile', style: text.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(user?.email ?? '', style: text.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Role: ${user?.role.name ?? ''}', style: text.bodyMedium),

            // Skills editor, students only
            if (user != null && user.role == UserRole.student) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('My skills', style: text.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('These power your matches.', style: text.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              if (user.skills.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: user.skills
                      .map((s) => Chip(
                            label: Text(s),
                            onDeleted: () => _removeSkill(user, s),
                          ))
                      .toList(),
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'e.g. Flutter'),
                      onSubmitted: (_) => _addSkill(user),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => _addSkill(user),
                    child: const Text('Add'),
                  ),
                ],
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