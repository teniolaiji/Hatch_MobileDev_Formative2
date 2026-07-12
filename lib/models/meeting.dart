import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  const Meeting({
    required this.scheduledAt,
    required this.link,
    this.note = '',
  });

  final DateTime scheduledAt;
  /// Google Meet, Zoom, or any URL the founder provides.
  final String link;
  final String note;

  Map<String, dynamic> toMap() => {
        'scheduledAt': scheduledAt.toIso8601String(),
        'link': link,
        'note': note,
      };

  factory Meeting.fromMap(Map<String, dynamic> map) => Meeting(
        scheduledAt: _parseDate(map['scheduledAt']),
        link: map['link'] as String? ?? '',
        note: map['note'] as String? ?? '',
      );

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
