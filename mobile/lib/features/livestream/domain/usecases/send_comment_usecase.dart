import '../entities/comment.dart';
import '../repositories/livestream_repository.dart';

class SendCommentParams {
  final String livestreamId;
  final String message;
  SendCommentParams({required this.livestreamId, required this.message});
}

class SendComment {
  final LivestreamRepository repository;
  SendComment(this.repository);
  Future<Comment> call(SendCommentParams params) =>
      repository.sendComment(params.livestreamId, params.message);
}
