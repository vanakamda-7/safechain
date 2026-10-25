class AppUser {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final List<String> emergencyContacts;

  const AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.emergencyContacts,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'user',
      emergencyContacts:
          List<String>.from(data['emergencyContacts'] ?? []),
    );
  }
}
