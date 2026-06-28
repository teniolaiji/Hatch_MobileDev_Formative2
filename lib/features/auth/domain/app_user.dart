enum UserRole { student, founder }

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String name;

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'role': role.name,
    'name': name,
  };
  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    uid: map['uid'] as String,
    email: map['email'] as String,
    role: UserRole.values.byName(map['role'] as String),
    name: map['name'] as String,
  );
}
