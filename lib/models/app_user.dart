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
    this.isVerified = false,
    this.savedOpportunities = const [],
    this.startupStage = '',
    this.website = '',
    this.aluCampus = '',
    this.aluProgram = '',
    this.aluYear = '',
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
  final bool isVerified;
  final List<String> savedOpportunities;
  /// Founder-only: startup stage (Idea / MVP / Growth / Scaling)
  final String startupStage;
  /// Founder-only: startup website URL
  final String website;
  /// Student-only: ALU campus (Rwanda / Mauritius)
  final String aluCampus;
  /// Student-only: ALU programme (e.g. Entrepreneurial Leadership)
  final String aluProgram;
  /// Student-only: current year (Year 1 – Year 4)
  final String aluYear;
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
    'isVerified': isVerified,
    'savedOpportunities': savedOpportunities,
    'startupStage': startupStage,
    'website': website,
    'aluCampus': aluCampus,
    'aluProgram': aluProgram,
    'aluYear': aluYear,
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
    isVerified: map['isVerified'] as bool? ?? false,
    savedOpportunities:
        List<String>.from(map['savedOpportunities'] as List? ?? []),
    startupStage: map['startupStage'] as String? ?? '',
    website: map['website'] as String? ?? '',
    aluCampus: map['aluCampus'] as String? ?? '',
    aluProgram: map['aluProgram'] as String? ?? '',
    aluYear: map['aluYear'] as String? ?? '',
  );
}
