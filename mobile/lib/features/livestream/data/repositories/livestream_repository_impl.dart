import "../../domain/entities/comment.dart";
import "../../domain/entities/livestream.dart";
import "../../domain/entities/voting_candidate.dart";
import "../../domain/repositories/livestream_repository.dart";
import "../datasources/livestream_local_data_source.dart";
import "../datasources/livestream_remote_data_source.dart";
import "../datasources/mock_livestream_data_source.dart";

class LivestreamRepositoryImpl implements LivestreamRepository {
  final LivestreamRemoteDataSource remoteDataSource;
  final LivestreamLocalDataSource localDataSource;

  LivestreamRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Livestream> getLivestream(String livestreamId) async {
    try {
      final ls = await remoteDataSource.getLivestream(livestreamId);
      await localDataSource.saveLivestream(ls);
      return ls;
    } catch (e) {
      return MockLivestream.livestream;
    }
  }

  @override
  Future<List<Comment>> getComments(String livestreamId) async {
    try {
      return await remoteDataSource.getComments(livestreamId);
    } catch (e) {
      return MockLivestream.mockComments;
    }
  }

  @override
  Future<Comment> sendComment(String livestreamId, String message) async {
    return await remoteDataSource.sendComment(livestreamId, message);
  }

  @override
  Future<List<VotingCandidate>> getVotingCandidates(String livestreamId) async {
    try {
      return await remoteDataSource.getVotingCandidates(livestreamId);
    } catch (e) {
      return MockLivestream.votingCandidates;
    }
  }

  @override
  Future<void> vote(String livestreamId, String candidateId) async {
    await remoteDataSource.vote(livestreamId, candidateId);
  }
}
