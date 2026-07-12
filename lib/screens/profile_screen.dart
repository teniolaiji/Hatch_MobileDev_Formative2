import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/initials_avatar.dart';
import 'package:hatch/components/verified_badge.dart';
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.highlight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(isStudent ? 'Student' : 'Founder',
                            style: text.labelSmall
                                ?.copyWith(color: AppColors.highlight)),
                      ),
                      // Founders only: verified status
                      if (!isStudent)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: user?.isVerified == true
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded,
                                        size: 14, color: AppColors.green),
                                    const SizedBox(width: 4),
                                    Text('Verified',
                                        style: text.labelSmall?.copyWith(
                                            color: AppColors.green)),
                                  ],
                                )
                              : Text('Not yet verified',
                                  style: text.labelSmall?.copyWith(
                                      color: AppColors.textSecondary)),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            if (isStudent && user != null) ...[
              const SizedBox(height: AppSpacing.xl),

              _Section(
                title: 'ALU context',
                onEdit: () => context.push(Routes.editAlu),
                child: _AluContext(user: user),
              ),

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

            // ── Founder-only sections ────────────────────────────────────────
            if (!isStudent && user != null) ...[
              const SizedBox(height: AppSpacing.xl),

              _Section(
                title: 'Startup pitch',
                onEdit: () => context.push(Routes.editStartup),
                child: user.bio.isEmpty
                    ? const _Empty(
                        'Describe what your startup does and the problem it solves.')
                    : Text(user.bio, style: text.bodyLarge),
              ),

              _Section(
                title: 'Startup details',
                onEdit: () => context.push(Routes.editStartup),
                child: (user.startupStage.isEmpty && user.website.isEmpty)
                    ? const _Empty('Add your stage and website.')
                    : _StartupDetails(
                        stage: user.startupStage,
                        website: user.website,
                      ),
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

class _AluContext extends StatelessWidget {
  const _AluContext({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasAny = user.aluCampus.isNotEmpty ||
        user.aluProgram.isNotEmpty ||
        user.aluYear.isNotEmpty;

    if (!hasAny) {
      return const _Empty('Add your campus, programme and year.');
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (user.aluCampus.isNotEmpty)
          _InfoChip(
            icon: Icons.location_on_outlined,
            label: user.aluCampus,
          ),
        if (user.aluProgram.isNotEmpty)
          _InfoChip(
            icon: Icons.school_outlined,
            label: user.aluProgram,
          ),
        if (user.aluYear.isNotEmpty)
          _InfoChip(
            icon: Icons.calendar_today_outlined,
            label: user.aluYear,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.navy),
          const SizedBox(width: 4),
          Text(
            label,
            style: text.labelSmall?.copyWith(color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}

class _StartupDetails extends StatelessWidget {
  const _StartupDetails({required this.stage, required this.website});
  final String stage;
  final String website;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stage.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.rocket_launch_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(stage, style: text.bodyMedium),
            ],
          ),
        if (stage.isNotEmpty && website.isNotEmpty)
          const SizedBox(height: AppSpacing.xs),
        if (website.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.link_rounded,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  website,
                  style: text.bodyMedium?.copyWith(color: AppColors.navy),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
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