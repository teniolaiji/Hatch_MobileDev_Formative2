import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/data/auth_repository.dart';
import 'package:hatch/providers/auth_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_spacing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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