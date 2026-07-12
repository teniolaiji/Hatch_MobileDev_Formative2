import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_spacing.dart';

class EditAboutScreen extends ConsumerStatefulWidget {
  const EditAboutScreen({super.key});
  @override
  ConsumerState<EditAboutScreen> createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends ConsumerState<EditAboutScreen> {
  final _ctrl = TextEditingController();
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    await ref
        .read(userRepositoryProvider)
        .updateProfile(uid, {'bio': _ctrl.text.trim()});
    ref.invalidate(currentUserProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    if (user != null && !_seeded) {
      _ctrl.text = user.bio;
      _seeded = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit about')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              TextField(
                controller: _ctrl,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'A short introduction about you.'),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: (_saving || user == null) ? null : () => _save(user.uid),
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}