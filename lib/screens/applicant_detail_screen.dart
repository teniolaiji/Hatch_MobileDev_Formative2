import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/initials_avatar.dart';
import 'package:hatch/components/status_badge.dart';
import 'package:hatch/models/app_user.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/models/meeting.dart';
import 'package:hatch/models/profile_entry.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  const ApplicantDetailScreen({super.key, required this.application});
  final Application application;

  @override
  ConsumerState<ApplicantDetailScreen> createState() =>
      _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen> {
  Future<void> _setStatus(ApplicationStatus status) async {
    try {
      await ref
          .read(applicationRepositoryProvider)
          .updateStatus(widget.application.id, status);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-advance submitted → reviewing the moment a founder opens this screen.
    if (widget.application.status == ApplicationStatus.submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(applicationRepositoryProvider)
            .updateStatus(widget.application.id, ApplicationStatus.reviewing);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // Profile is optional enrichment — the screen always shows the application
    // data from the Application object. If Firestore rules block cross-user
    // reads, we degrade silently rather than showing an error page.
    final profileAsync =
        ref.watch(userByIdProvider(widget.application.applicantId));
    final user = profileAsync.value; // null while loading or on error

    // Watch live status so the badge and buttons reflect any real-time update.
    final live = ref
            .watch(startupApplicationsProvider)
            .value
            ?.firstWhere((a) => a.id == widget.application.id,
                orElse: () => widget.application) ??
        widget.application;

    // Show Accept/Reject for both submitted and reviewing — neither is a
    // final decision yet. Only accepted/rejected hides the action bar.
    final isPending = live.status == ApplicationStatus.submitted ||
        live.status == ApplicationStatus.reviewing;

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Identity ──────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  InitialsAvatar(name: widget.application.applicantName),
                  const SizedBox(height: AppSpacing.md),
                  Text(widget.application.applicantName,
                      style: text.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  StatusBadge(status: live.status),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Application ───────────────────────────────────────────────
            _Block(
              title: 'Applied for',
              child: Text(widget.application.opportunityTitle,
                  style: text.bodyLarge),
            ),
            if (widget.application.availability.isNotEmpty)
              _Block(
                title: 'Availability',
                child: Text(widget.application.availability,
                    style: text.bodyLarge),
              ),
            if (widget.application.message.isNotEmpty)
              _Block(
                title: 'Cover letter',
                child:
                    Text(widget.application.message, style: text.bodyLarge),
              ),
            if (widget.application.portfolioUrl.isNotEmpty)
              _Block(
                title: 'Portfolio / LinkedIn',
                child: _UrlTile(url: widget.application.portfolioUrl),
              ),
            if (widget.application.cvUrl.isNotEmpty)
              _Block(
                title: 'CV',
                child: _CvTile(url: widget.application.cvUrl),
              ),

            // ── Full profile ──────────────────────────────────────────────
            if (profileAsync.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (profileAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Text(
                  'Profile could not be loaded. Check your Firestore read rules.',
                  style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              )
            else if (user != null) ...[
              // ALU context row
              if (user.aluCampus.isNotEmpty ||
                  user.aluProgram.isNotEmpty ||
                  user.aluYear.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (user.aluCampus.isNotEmpty)
                        _AluChip(
                            icon: Icons.location_on_outlined,
                            label: user.aluCampus),
                      if (user.aluProgram.isNotEmpty)
                        _AluChip(
                            icon: Icons.school_outlined,
                            label: user.aluProgram),
                      if (user.aluYear.isNotEmpty)
                        _AluChip(
                            icon: Icons.calendar_today_outlined,
                            label: user.aluYear),
                    ],
                  ),
                ),
              if (user.bio.isNotEmpty)
                _Block(
                    title: 'About',
                    child: Text(user.bio, style: text.bodyLarge)),
              if (user.skills.isNotEmpty)
                _Block(title: 'Skills', child: _Chips(items: user.skills)),
              if (user.interests.isNotEmpty)
                _Block(
                    title: 'Interests', child: _Chips(items: user.interests)),
              if (user.experience.isNotEmpty)
                _Block(
                    title: 'Experience',
                    child: _Entries(entries: user.experience)),
              if (user.education.isNotEmpty)
                _Block(
                    title: 'Education',
                    child: _Entries(entries: user.education)),
            ],

            // ── Accepted: contact reveal + meetings ───────────────────
            if (live.status == ApplicationStatus.accepted) ...[
              // Contact reveal
              _Block(
                title: 'Contact',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (live.applicantEmail.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          final uri =
                              Uri.parse('mailto:${live.applicantEmail}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 16, color: AppColors.navy),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                live.applicantEmail,
                                style:
                                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: AppColors.navy,
                                          decoration: TextDecoration.underline,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Scheduled meetings
              _Block(
                title: 'Meetings',
                child: live.meetings.isEmpty
                    ? Text(
                        'No meetings scheduled yet. Use the button below to add one.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      )
                    : Column(
                        children: live.meetings
                            .map((m) => _FounderMeetingCard(meeting: m))
                            .toList(),
                      ),
              ),
            ],

            // Bottom padding so content clears the action bar
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      bottomNavigationBar: isPending
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _setStatus(ApplicationStatus.rejected),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _setStatus(ApplicationStatus.accepted),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            )
          : live.status == ApplicationStatus.accepted
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: const Text('Schedule meeting'),
                    onPressed: () => _showScheduleSheet(live),
                  ),
                )
              : null,
    );
  }

  void _showScheduleSheet(Application live) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ScheduleMeetingSheet(application: live),
    );
  }
}

// ── Founder's meeting card (simpler — no Join button, founder already has link) ─

class _FounderMeetingCard extends StatelessWidget {
  const _FounderMeetingCard({required this.meeting});
  final Meeting meeting;

  static String _weekday(int w) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

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
                isPast ? Icons.event_available_rounded : Icons.event_rounded,
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
                      style:
                          text.labelSmall?.copyWith(color: AppColors.taupe)),
                ),
            ],
          ),
          if (meeting.link.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              meeting.link,
              style: text.bodySmall?.copyWith(
                color: AppColors.stone,
                overflow: TextOverflow.ellipsis,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (meeting.note.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(meeting.note,
                style:
                    text.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// ── Schedule meeting bottom sheet ─────────────────────────────────────────────

class _ScheduleMeetingSheet extends ConsumerStatefulWidget {
  const _ScheduleMeetingSheet({required this.application});
  final Application application;

  @override
  ConsumerState<_ScheduleMeetingSheet> createState() =>
      _ScheduleMeetingSheetState();
}

class _ScheduleMeetingSheetState
    extends ConsumerState<_ScheduleMeetingSheet> {
  final _linkCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _saving = false;

  @override
  void dispose() {
    _linkCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date and time.')),
      );
      return;
    }
    if (_linkCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a meeting link.')),
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final meeting = Meeting(
      scheduledAt: scheduledAt,
      link: _linkCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
    );

    setState(() => _saving = true);
    try {
      await ref
          .read(applicationRepositoryProvider)
          .addMeeting(widget.application.id, meeting);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not schedule: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    String fmtDate(DateTime d) =>
        '${const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d.weekday-1]}, '
        '${d.day} ${const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month-1]} ${d.year}';

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text('Schedule a meeting', style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'with ${widget.application.applicantName}',
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Date + time row
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  icon: Icons.calendar_today_rounded,
                  label: _selectedDate != null
                      ? fmtDate(_selectedDate!)
                      : 'Pick date',
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PickerTile(
                  icon: Icons.access_time_rounded,
                  label: _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Pick time',
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Meeting link
          Text('Meeting link *',
              style:
                  text.titleSmall?.copyWith(color: AppColors.navy)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _linkCtrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'https://meet.google.com/…',
              prefixIcon: Icon(Icons.videocam_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Note (optional)
          Text('Note (optional)',
              style:
                  text.titleSmall?.copyWith(color: AppColors.navy)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Bring your portfolio, we\'ll discuss your fit…',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save meeting'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.navy),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: text.bodyMedium?.copyWith(color: AppColors.navy),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: items.map((s) => Chip(label: Text(s))).toList(),
      );
}

class _UrlTile extends StatelessWidget {
  const _UrlTile({required this.url});
  final String url;

  Future<void> _open() async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: _open,
      child: Row(
        children: [
          const Icon(Icons.link_rounded, size: 16, color: AppColors.navy),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              url,
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

class _CvTile extends StatelessWidget {
  const _CvTile({required this.url});
  final String url;

  Future<void> _open() async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: _open,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.navy.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded,
                size: 18, color: AppColors.navy),
            const SizedBox(width: AppSpacing.sm),
            Text('View CV',
                style:
                    text.labelMedium?.copyWith(color: AppColors.navy)),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.open_in_new_rounded,
                size: 14, color: AppColors.stone),
          ],
        ),
      ),
    );
  }
}

class _AluChip extends StatelessWidget {
  const _AluChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.navy),
          const SizedBox(width: 4),
          Text(label,
              style: text.labelSmall?.copyWith(color: AppColors.navy)),
        ],
      ),
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({required this.entries});
  final List<ProfileEntry> entries;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: text.titleMedium),
                    Text('${e.place}  ·  ${e.year}', style: text.bodyMedium),
                  ],
                ),
              ))
          .toList(),
    );
  }
}