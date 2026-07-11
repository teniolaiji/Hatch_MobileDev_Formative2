import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/initials_avatar.dart';
import 'package:hatch/data/auth_repository.dart';
import 'package:hatch/models/app_user.dart';
import 'package:hatch/models/profile_entry.dart';
import 'package:hatch/providers/auth_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
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
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.highlight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(isStudent ? 'Student' : 'Founder',
                        style: text.labelSmall
                            ?.copyWith(color: AppColors.highlight)),
                  ),
                ],
              ),
            ),

            if (isStudent && user != null) ...[
              const SizedBox(height: AppSpacing.xl),

              _Section(
                title: 'About',
                onEdit: () => context.push(Routes.editAbout),
                child: user.bio.isEmpty
                    ? const _Empty('Add a short introduction.')
                    : Text(user.bio, style: text.bodyLarge),
              ),

              _Section(
                title: 'Skills',
                onEdit: () => context.push(Routes.editSkills),
                child: user.skills.isEmpty
                    ? const _Empty('Add skills to power your matches.')
                    : _Chips(items: user.skills),
              ),

              _Section(
                title: 'Interests',
                onEdit: () => context.push(Routes.editInterests),
                child: user.interests.isEmpty
                    ? const _Empty('Add your interests.')
                    : _Chips(items: user.interests),
              ),

              _Section(
                title: 'Experience',
                onEdit: () => context.push(Routes.editExperience),
                child: user.experience.isEmpty
                    ? const _Empty('Add past roles or projects.')
                    : _EntryList(entries: user.experience),
              ),

              _Section(
                title: 'Education',
                onEdit: () => context.push(Routes.editEducation),
                child: user.education.isEmpty
                    ? const _Empty('Add your education.')
                    : _EntryList(entries: user.education),
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

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.onEdit, required this.child});
  final String title;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: text.titleMedium),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: AppColors.textFaint));
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

class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries});
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