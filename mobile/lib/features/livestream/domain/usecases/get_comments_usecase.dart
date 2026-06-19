import '../entities/comment.dart';
import '../repositories/livestream_repository.dart';

class GetComments {
  final LivestreamRepository repository;
  GetComments(this.repository);
  Future<List<Comment>> call(String livestreamId) =>
      repository.getComments(livestreamId);
}
