import 'package:hatch/models/profile_entry.dart';

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
    this.experience = const [],
    this.education = const [],
  });

  final String uid;
  final String email;
  final UserRole role;
  final String name;
  final List<String> skills;
  final String bio;
  final List<String> interests;
  final List<ProfileEntry> experience;
  final List<ProfileEntry> education;
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'role': role.name,
    'name': name,
    'skills': skills,
    'bio': bio,
    'interests': interests,
    'experience': experience.map((e) => e.toMap()).toList(),
    'education': education.map((e) => e.toMap()).toList(),
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    uid: map['uid']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    role: UserRole.values.byName(map['role']?.toString() ?? 'student'),
    name: map['name']?.toString() ?? '',
    skills: List<String>.from(map['skills'] as List? ?? []),
    bio: map['bio'] as String? ?? '',
    interests: List<String>.from(map['interests'] as List? ?? []),
    experience: (map['experience'] as List? ?? [])
        .map((e) => ProfileEntry.fromMap(e as Map<String, dynamic>))
        .toList(),
    education: (map['education'] as List? ?? [])
        .map((e) => ProfileEntry.fromMap(e as Map<String, dynamic>))
        .toList(),
  );
}
