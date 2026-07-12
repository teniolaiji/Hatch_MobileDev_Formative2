import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  const ApplyScreen({super.key, required this.opportunity});
  final Opportunity opportunity;

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _coverCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _cvCtrl = TextEditingController();

  String _availability = '';

  bool _submitting = false;
  bool _alreadyApplied = false;
  bool _checkingApplied = true;

  static const _availabilityOptions = [
    'Immediately',
    '2 weeks',
    '1 month',
    'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    _checkAlreadyApplied();
  }

  @override
  void dispose() {
    _coverCtrl.dispose();
    _portfolioCtrl.dispose();
    _cvCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkAlreadyApplied() async {
    final uid = ref.read(currentUserProvider).value?.uid;
    if (uid == null) {
      setState(() => _checkingApplied = false);
      return;
    }
    final already = await ref.read(applicationRepositoryProvider).hasApplied(
          applicantId: uid,
          opportunityId: widget.opportunity.id,
        );
    if (mounted) {
      setState(() {
        _alreadyApplied = already;
        _checkingApplied = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_coverCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a cover letter.')),
      );
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _submitting = true);

    try {
      await ref.read(applicationRepositoryProvider).submit(
            Application(
              id: '',
              opportunityId: widget.opportunity.id,
              opportunityTitle: widget.opportunity.title,
              startupId: widget.opportunity.startupId,
              startupName: widget.opportunity.startupName,
              applicantId: user.uid,
              applicantName: user.name,
              message: _coverCtrl.text.trim(),
              portfolioUrl: _portfolioCtrl.text.trim(),
              availability: _availability,
              cvUrl: _cvCtrl.text.trim(),
              applicantEmail: user.email,
              status: ApplicationStatus.submitted,
              createdAt: DateTime.now(),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final busy = _submitting || _checkingApplied;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: SafeArea(
        child: _alreadyApplied
            ? _AlreadyApplied(title: widget.opportunity.title)
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // ── Role header ─────────────────────────────────────
                  Text(
                    widget.opportunity.startupName.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                      color: AppColors.stone,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(widget.opportunity.title, style: text.headlineMedium),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Cover letter ────────────────────────────────────
                  _Label('Cover letter', required: true),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tell us why you\'re a great fit and what you\'d bring to this role.',
                    style: text.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _coverCtrl,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText:
                          'I am excited about this opportunity because…',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Availability ────────────────────────────────────
                  _Label('Availability'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _availabilityOptions.map((opt) {
                      final selected = _availability == opt;
                      return GestureDetector(
                        onTap: () => setState(() => _availability =
                            selected ? '' : opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.navy
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: selected
                                  ? AppColors.navy
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            opt,
                            style: text.labelMedium?.copyWith(
                              color: selected
                                  ? AppColors.cream
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Portfolio / LinkedIn ────────────────────────────
                  _Label('Portfolio / LinkedIn'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _portfolioCtrl,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'https://linkedin.com/in/yourname',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── CV link ─────────────────────────────────────────
                  _Label('CV link'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Paste a shareable link to your CV — Google Drive, Dropbox, or any public URL.',
                    style: text.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _cvCtrl,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'https://drive.google.com/…',
                      prefixIcon: Icon(Icons.picture_as_pdf_rounded),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Submit ──────────────────────────────────────────
                  ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit application'),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
      ),
    );
  }
}

// ── Already applied ───────────────────────────────────────────────────────────

class _AlreadyApplied extends StatelessWidget {
  const _AlreadyApplied({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 48, color: AppColors.green),
            const SizedBox(height: AppSpacing.md),
            Text('Already applied', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You\'ve already submitted an application for $title.',
              style: text.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text, {this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: AppColors.navy);
    return Row(
      children: [
        Text(text, style: style),
        if (required) ...[
          const SizedBox(width: 3),
          Text(' *', style: style?.copyWith(color: AppColors.danger)),
        ],
      ],
    );
  }
}
