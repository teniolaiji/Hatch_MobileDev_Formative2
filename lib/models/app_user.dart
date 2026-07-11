enum UserRole { student, founder }

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.skills = const [],
  });

  final String uid;
  final String email;
  final UserRole role;
  final String name;
  final List<String> skills;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'role': role.name,
        'name': name,
        'skills': skills,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        role: UserRole.values.byName(map['role']?.toString() ?? 'student'),
        name: map['name']?.toString() ?? '',
        skills: List<String>.from(map['skills'] as List? ?? []),
      );
}
