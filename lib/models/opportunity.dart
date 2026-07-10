import 'package:cloud_firestore/cloud_firestore.dart';

enum LocationType { remote, onsite }

class Opportunity {
  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.createdAt,
    required this.location,
    required this.timeCommitment,
    this.deadline,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final DateTime createdAt;
  final LocationType location;
  final String timeCommitment;
  final DateTime? deadline;

  Map<String, dynamic> toMap() => {
    'startupId': startupId,
    'startupName': startupName,
    'title': title,
    'description': description,
    'requiredSkills': requiredSkills,
    'createdAt': createdAt.toIso8601String(),
    'location': location.name,
    'timeCommitment': timeCommitment,
    'deadline': deadline?.toIso8601String(),
  };

  factory Opportunity.fromMap(String id, Map<String, dynamic> map) =>
      Opportunity(
        id: id,
        startupId: map['startupId']?.toString() ?? '',
        startupName: map['startupName']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        requiredSkills: map['requiredSkills'] is List
            ? List<String>.from(map['requiredSkills'] as List)
            : [],
        createdAt: _parseDate(map['createdAt']),
        location: LocationType.values.byName(
          map['location'] as String? ?? 'onsite',
        ),
        timeCommitment: map['timeCommitment'] as String? ?? '',
        deadline: map['deadline'] == null ? null : _parseDate(map['deadline']),
      );

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
