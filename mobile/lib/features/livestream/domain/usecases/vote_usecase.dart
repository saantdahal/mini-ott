import '../repositories/livestream_repository.dart';

class VoteParams {
  final String livestreamId;
  final String candidateId;
  VoteParams({required this.livestreamId, required this.candidateId});
}

class Vote {
  final LivestreamRepository repository;
  Vote(this.repository);
  Future<void> call(VoteParams params) =>
      repository.vote(params.livestreamId, params.candidateId);
}
