class Startup {
  const Startup({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.verified,
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final bool verified;

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'name': name,
        'description': description,
        'verified': verified,
      };

  factory Startup.fromMap(String id, Map<String, dynamic> map) => Startup(
        id: id,
        ownerId: map['ownerId'] as String,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        verified: map['verified'] as bool? ?? false,
      );
}
