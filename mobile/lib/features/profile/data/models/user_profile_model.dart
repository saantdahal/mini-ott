class UserProfileModel {
  const UserProfileModel({
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
  final String? createdAt;
  final bool isEmailVerified;
  final String status;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      phone: json['phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      country: json['country']?.toString(),
      createdAt: json['created_at']?.toString(),
      isEmailVerified: json['email_verified'] ?? false,
      status: (json['status'] ?? 'active').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'country': country,
      'created_at': createdAt,
      'email_verified': isEmailVerified,
      'status': status,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    String? gender,
    String? dateOfBirth,
    String? country,
    String? createdAt,
    bool? isEmailVerified,
    String? status,
  }) {
    return UserProfileModel(
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
}
