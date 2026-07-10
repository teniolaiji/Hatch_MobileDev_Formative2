import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_spacing.dart';

class FounderHomeScreen extends ConsumerWidget {
  const FounderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${user?.name ?? ''}', style: text.displayMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('Manage your roles and review applicants here.',
                  style: text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}