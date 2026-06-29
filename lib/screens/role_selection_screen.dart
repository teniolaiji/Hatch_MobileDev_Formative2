import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';
import '../components/app_text_field.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  final _name = TextEditingController();
  UserRole? _selected;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_selected == null || _name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Pick a role and enter your name.')));
      return;
    }
    setState(() => _saving = true);

    final authUser = ref.read(authRepositoryProvider).currentUser!;
    final user = AppUser(
      uid: authUser.uid,
      email: authUser.email ?? '',
      role: _selected!,
      name: _name.text.trim(),
    );

    try {
      await ref.read(userRepositoryProvider).createUser(user);
      ref.invalidate(currentUserProvider);
      // Navigation is handled automatically by the router when currentUserProvider resolves.
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text('How will you use Hatch?', style: text.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('You can focus on one path to start.',
                  style: text.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              _RoleCard(
                title: 'I\'m a student',
                subtitle: 'Find micro-internships matched to my skills.',
                icon: Icons.school_outlined,
                selected: _selected == UserRole.student,
                onTap: () => setState(() => _selected = UserRole.student),
              ),
              const SizedBox(height: AppSpacing.md),
              _RoleCard(
                title: 'I run a startup',
                subtitle: 'Post roles and find student talent.',
                icon: Icons.rocket_launch_outlined,
                selected: _selected == UserRole.founder,
                onTap: () => setState(() => _selected = UserRole.founder),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Your name',
                hint: 'First and last name',
                controller: _name,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _saving ? null : _continue,
                child: _saving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: text.bodyMedium),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
