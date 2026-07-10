import 'package:flutter/material.dart';
import 'package:hatch/theme/app_spacing.dart';

class PostOpportunityScreen extends StatelessWidget {
  const PostOpportunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Post a role')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Role creation coming soon.',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
