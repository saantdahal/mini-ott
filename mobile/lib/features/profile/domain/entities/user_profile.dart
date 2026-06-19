class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.country,
    this.createdAt,
    this.isEmailVerified = false,
    this.status = 'active',
  });

  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final String? gender;
  final String? dateOfBirth;
  final String? country;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final String status;

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    String? gender,
    String? dateOfBirth,
    String? country,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, name: $name, phone: $phone, '
        'avatarUrl: $avatarUrl, gender: $gender, dateOfBirth: $dateOfBirth, '
        'country: $country, createdAt: $createdAt, isEmailVerified: $isEmailVerified, '
        'status: $status)';
  }
}
