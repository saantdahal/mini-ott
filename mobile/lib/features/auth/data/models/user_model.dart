class UserModel {
  const UserModel({required this.id, required this.email, required this.name});

  final String id;
  final String email;
  final String name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}
