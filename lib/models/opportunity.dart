class Opportunity {
  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.createdAt,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'startupId': startupId,
        'startupName': startupName,
        'title': title,
        'description': description,
        'requiredSkills': requiredSkills,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Opportunity.fromMap(String id, Map<String, dynamic> map) => Opportunity(
        id: id,
        startupId: map['startupId'] as String,
        startupName: map['startupName'] as String? ?? '',
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        requiredSkills: List<String>.from(map['requiredSkills'] as List? ?? []),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
