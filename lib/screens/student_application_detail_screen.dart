import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/status_badge.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/models/meeting.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentApplicationDetailScreen extends ConsumerStatefulWidget {
  const StudentApplicationDetailScreen({super.key, required this.application});
  final Application application;

  @override
  ConsumerState<StudentApplicationDetailScreen> createState() =>
      _StudentApplicationDetailScreenState();
}

class _StudentApplicationDetailScreenState
    extends ConsumerState<StudentApplicationDetailScreen> {
  bool _withdrawing = false;

  bool _canWithdraw(ApplicationStatus status) =>
      status == ApplicationStatus.submitted ||
      status == ApplicationStatus.reviewing;

  Future<void> _confirmWithdraw(Application live) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: Text(
          'Your application to ${live.startupName} will be permanently removed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.danger),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _withdrawing = true);
    try {
      await ref
          .read(applicationRepositoryProvider)
          .withdraw(live.id);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _withdrawing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not withdraw: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // Watch live so status + meetings update in real-time
    final live = ref
            .watch(myApplicationsProvider)
            .value
            ?.firstWhere((a) => a.id == widget.application.id,
                orElse: () => widget.application) ??
        widget.application;

    final isAccepted = live.status == ApplicationStatus.accepted;

    // Fetch founder profile for contact info (only useful if accepted)
    final founderAsync =
        ref.watch(userByIdProvider(widget.application.startupId));
    final founder = founderAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Application')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Header ───────────────────────────────────────────────
            Text(
              widget.application.startupName.toUpperCase(),
              style: text.labelSmall?.copyWith(
                color: AppColors.stone,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(widget.application.opportunityTitle,
                style: text.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            StatusBadge(status: live.status),

            // ── Accepted: congratulations + contact ──────────────────
            if (isAccepted) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.celebration_rounded,
                            color: AppColors.green, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text('You\'ve been accepted!',
                            style: text.titleSmall
                                ?.copyWith(color: AppColors.green)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${widget.application.startupName} wants you on the team. '
                      'Reach out below or wait for them to schedule a meeting.',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Contact info
              _Block(
                title: 'Contact',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (founder?.email.isNotEmpty ?? false)
                      _ContactRow(
                        icon: Icons.email_outlined,
                        label: founder!.email,
                        onTap: () => _launch('mailto:${founder.email}'),
                      ),
                    if (founder?.website.isNotEmpty ?? false) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _ContactRow(
                        icon: Icons.link_rounded,
                        label: founder!.website,
                        onTap: () => _launch(founder.website),
                      ),
                    ],
                    if ((founder?.email.isEmpty ?? true) &&
                        (founder?.website.isEmpty ?? true))
                      Text(
                        'Contact details not yet available.',
                        style: text.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),

              // Scheduled meetings
              if (live.meetings.isNotEmpty) ...[
                _Block(
                  title: 'Scheduled meetings',
                  child: Column(
                    children: live.meetings
                        .map((m) => _MeetingCard(meeting: m))
                        .toList(),
                  ),
                ),
              ] else ...[
                _Block(
                  title: 'Scheduled meetings',
                  child: Text(
                    'No meetings scheduled yet. The founder will reach out soon.',
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],

            // ── Submitted details ─────────────────────────────────────
            const SizedBox(height: AppSpacing.xl),
            Text('Your application',
                style: text.titleMedium
                    ?.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.md),

            if (widget.application.availability.isNotEmpty)
              _Block(
                title: 'Availability',
                child: Text(widget.application.availability,
                    style: text.bodyMedium),
              ),
            if (widget.application.message.isNotEmpty)
              _Block(
                title: 'Cover letter',
                child: Text(widget.application.message,
                    style: text.bodyMedium),
              ),
            if (widget.application.portfolioUrl.isNotEmpty)
              _Block(
                title: 'Portfolio / LinkedIn',
                child: GestureDetector(
                  onTap: () => _launch(widget.application.portfolioUrl),
                  child: Text(
                    widget.application.portfolioUrl,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.navy,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            if (widget.application.cvUrl.isNotEmpty)
              _Block(
                title: 'CV',
                child: GestureDetector(
                  onTap: () => _launch(widget.application.cvUrl),
                  child: Text(
                    widget.application.cvUrl,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.navy,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      bottomNavigationBar: _canWithdraw(live.status)
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: OutlinedButton(
                onPressed: _withdrawing
                    ? null
                    : () => _confirmWithdraw(live),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                child: _withdrawing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.danger),
                      )
                    : const Text('Withdraw application'),
              ),
            )
          : null,
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: text.titleSmall
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.navy),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(
                color: AppColors.navy,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting});
  final Meeting meeting;

  static String _weekday(int w) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  Future<void> _join() async {
    final uri = Uri.tryParse(meeting.link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isPast = meeting.scheduledAt.isBefore(DateTime.now());
    final d = meeting.scheduledAt;
    final dateLabel =
        '${_weekday(d.weekday)}, ${d.day} ${_month(d.month)} ${d.year}  •  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isPast
            ? AppColors.surface
            : AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isPast
              ? AppColors.border
              : AppColors.navy.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPast
                    ? Icons.event_available_rounded
                    : Icons.event_rounded,
                size: 16,
                color: isPast ? AppColors.stone : AppColors.navy,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  dateLabel,
                  style: text.bodyMedium?.copyWith(
                    color: isPast ? AppColors.stone : AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isPast)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.stone.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text('Past',
                      style: text.labelSmall
                          ?.copyWith(color: AppColors.taupe)),
                ),
            ],
          ),
          if (meeting.note.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(meeting.note,
                style: text.bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
          if (meeting.link.isNotEmpty && !isPast) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _join,
                icon: const Icon(Icons.videocam_rounded, size: 16),
                label: const Text('Join meeting'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
