import '../entities/voting_candidate.dart';
import '../repositories/livestream_repository.dart';

class GetVotingCandidates {
  final LivestreamRepository repository;
  GetVotingCandidates(this.repository);
  Future<List<VotingCandidate>> call(String livestreamId) =>
      repository.getVotingCandidates(livestreamId);
}
