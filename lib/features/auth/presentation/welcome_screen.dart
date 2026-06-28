import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('Hatch', style: text.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Real experience with ALU startups, matched to your skills.',
                style: text.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push(Routes.signup),
                child: const Text('Create account'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => context.push(Routes.login),
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/alu_logo.png',
                      height: 24,
                      width: 24,
                      color: AppColors.background,
                      colorBlendMode: BlendMode.multiply,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Built for the ALU community', style: text.labelSmall),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
