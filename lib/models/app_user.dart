enum UserRole { student, founder }

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.skills = const [],
    this.bio = '',
    this.interests = const [],
    this.experience = '',
    this.education = '',
  });

  final String uid;
  final String email;
  final UserRole role;
  final String name;
  final List<String> skills;
  final String bio;
  final List<String> interests;
  final String experience;
  final String education;

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'role': role.name,
    'name': name,
    'skills': skills,
    'bio': bio,
    'interests': interests,
    'experience': experience,
    'education': education,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    uid: map['uid']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    role: UserRole.values.byName(map['role']?.toString() ?? 'student'),
    name: map['name']?.toString() ?? '',
    skills: List<String>.from(map['skills'] as List? ?? []),
    bio: map['bio'] as String? ?? '',
    interests: List<String>.from(map['interests'] as List? ?? []),
    experience: map['experience'] as String? ?? '',
    education: map['education'] as String? ?? '',
  );
}
