import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_spacing.dart';

/// Reusable chip-based editor for any List<String> profile field.
/// Use for skills, interests, or any future tag-style field.
class EditTagsScreen extends ConsumerStatefulWidget {
  const EditTagsScreen({
    super.key,
    required this.title,
    required this.field,
    required this.readTags,
  });

  final String title;                            // e.g. 'Skills'
  final String field;                            // Firestore field key
  final List<String> Function(dynamic) readTags; // extracts the list from AppUser

  @override
  ConsumerState<EditTagsScreen> createState() => _EditTagsScreenState();
}

class _EditTagsScreenState extends ConsumerState<EditTagsScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save(String uid, List<String> tags) async {
    await ref
        .read(userRepositoryProvider)
        .updateProfile(uid, {widget.field: tags});
    ref.invalidate(currentUserProvider);
  }

  void _add(String uid, List<String> current) {
    final tag = _ctrl.text.trim();
    if (tag.isEmpty || current.map((t) => t.toLowerCase()).contains(tag.toLowerCase())) {
      return;
    }
    _ctrl.clear();
    _save(uid, [...current, tag]);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final tags = user == null ? <String>[] : widget.readTags(user);

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.title.toLowerCase()}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Add ${widget.title.toLowerCase()}…',
                      ),
                      onSubmitted:
                          user == null ? null : (_) => _add(user.uid, tags),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed:
                        user == null ? null : () => _add(user.uid, tags),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (tags.isEmpty)
                Text(
                  'No ${widget.title.toLowerCase()} yet.',
                  style: text.bodyMedium,
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: tags
                      .map(
                        (t) => Chip(
                          label: Text(t),
                          onDeleted: () {
                            final updated = [...tags]..remove(t);
                            _save(user!.uid, updated);
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
