import "../../domain/entities/comment.dart";

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.userAvatar,
    required super.message,
    required super.createdAt,
    super.likes = 0,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      userAvatar: json['user_avatar'] ?? "",
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      likes: json['likes'] ?? 0,
    );
  }
}
