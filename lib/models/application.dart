import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatch/models/meeting.dart';

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
    this.portfolioUrl = '',
    this.availability = '',
    this.cvUrl = '',
    this.applicantEmail = '',
    this.meetings = const [],
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String applicantId;
  final String applicantName;
  /// Cover letter / motivation
  final String message;
  final ApplicationStatus status;
  final DateTime createdAt;
  /// Portfolio or LinkedIn URL (optional)
  final String portfolioUrl;
  /// When the applicant can start (e.g. "Immediately", "2 weeks")
  final String availability;
  /// Firebase Storage download URL for the attached CV (optional)
  final String cvUrl;
  /// Denormalised at submission so founders can contact without a Firestore lookup
  final String applicantEmail;
  /// Meetings scheduled by the founder after acceptance
  final List<Meeting> meetings;

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
        'portfolioUrl': portfolioUrl,
        'availability': availability,
        'cvUrl': cvUrl,
        'applicantEmail': applicantEmail,
        'meetings': meetings.map((m) => m.toMap()).toList(),
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
        portfolioUrl: map['portfolioUrl'] as String? ?? '',
        availability: map['availability'] as String? ?? '',
        cvUrl: map['cvUrl'] as String? ?? '',
        applicantEmail: map['applicantEmail'] as String? ?? '',
        meetings: (map['meetings'] as List? ?? [])
            .map((m) => Meeting.fromMap(m as Map<String, dynamic>))
            .toList(),
      );

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
