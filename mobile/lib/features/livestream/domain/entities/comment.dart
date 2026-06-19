class Comment {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String message;
  final DateTime createdAt;
  final int likes;

  const Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.message,
    required this.createdAt,
    this.likes = 0,
  });
}
