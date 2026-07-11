import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/models/profile_entry.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

// Edits a list of ProfileEntry items
class EditEntriesScreen extends ConsumerStatefulWidget {
  const EditEntriesScreen({
    super.key,
    required this.title,
    required this.field,
    required this.readEntries,
  });

  final String title;   // "Experience" or "Education"
  final String field;   // Firestore field name
  final List<ProfileEntry> Function(dynamic user) readEntries;

  @override
  ConsumerState<EditEntriesScreen> createState() => _EditEntriesScreenState();
}

class _EditEntriesScreenState extends ConsumerState<EditEntriesScreen> {
  Future<void> _save(String uid, List<ProfileEntry> entries) async {
    await ref.read(userRepositoryProvider).updateProfile(
        uid, {widget.field: entries.map((e) => e.toMap()).toList()});
    ref.invalidate(currentUserProvider);
  }

  Future<void> _addDialog(String uid, List<ProfileEntry> current) async {
    final titleCtrl = TextEditingController();
    final placeCtrl = TextEditingController();
    final yearCtrl = TextEditingController();

    final entry = await showDialog<ProfileEntry>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${widget.title.toLowerCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl,
                decoration: const InputDecoration(hintText: 'Title / role')),
            TextField(controller: placeCtrl,
                decoration: const InputDecoration(hintText: 'Place')),
            TextField(controller: yearCtrl,
                decoration: const InputDecoration(hintText: 'Year(s)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
                context,
                ProfileEntry(
                  title: titleCtrl.text.trim(),
                  place: placeCtrl.text.trim(),
                  year: yearCtrl.text.trim(),
                )),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (entry != null && entry.title.isNotEmpty) {
      await _save(uid, [...current, entry]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final entries = user == null ? <ProfileEntry>[] : widget.readEntries(user);

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.title.toLowerCase()}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            user == null ? null : () => _addDialog(user.uid, entries),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Text('Nothing here yet. Tap Add.',
                    style: text.bodyMedium))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final e = entries[i];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title, style: text.titleMedium),
                              Text('${e.place}  ·  ${e.year}',
                                  style: text.bodyMedium),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            final updated = [...entries]..removeAt(i);
                            _save(user!.uid, updated);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}