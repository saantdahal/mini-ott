import '../entities/comment.dart';
import '../entities/livestream.dart';
import '../entities/voting_candidate.dart';

abstract class LivestreamRepository {
  Future<Livestream> getLivestream(String livestreamId);
  Future<List<Comment>> getComments(String livestreamId);
  Future<Comment> sendComment(String livestreamId, String message);
  Future<List<VotingCandidate>> getVotingCandidates(String livestreamId);
  Future<void> vote(String livestreamId, String candidateId);
}
