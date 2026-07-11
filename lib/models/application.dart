import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { submitted, reviewing, accepted, rejected }

class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.applicantId,
    required this.applicantName,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String applicantId;
  final String applicantName;
  final String message;
  final ApplicationStatus status;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'opportunityId': opportunityId,
        'opportunityTitle': opportunityTitle,
        'startupId': startupId,
        'startupName': startupName,
        'applicantId': applicantId,
        'applicantName': applicantName,
        'message': message,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Application.fromMap(String id, Map<String, dynamic> map) =>
      Application(
        id: id,
        opportunityId: map['opportunityId'] as String? ?? '',
        opportunityTitle: map['opportunityTitle'] as String? ?? '',
        startupId: map['startupId'] as String? ?? '',
        startupName: map['startupName'] as String? ?? '',
        applicantId: map['applicantId'] as String? ?? '',
        applicantName: map['applicantName'] as String? ?? '',
        message: map['message'] as String? ?? '',
        status: ApplicationStatus.values.byName(
            map['status'] as String? ?? 'submitted'),
        createdAt: _parseDate(map['createdAt']),
      );

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
