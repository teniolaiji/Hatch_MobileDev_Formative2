import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hatch', style: text.displayMedium),
              const SizedBox(height: 8),
              Text('Sign in to continue', style: text.bodyMedium),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    ref.read(authRepositoryProvider).signInAnonymously(),
                child: const Text('Sign in (temporary)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}