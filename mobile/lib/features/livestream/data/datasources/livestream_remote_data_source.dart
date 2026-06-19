import 'package:dio/dio.dart';

import '../models/comment_model.dart';
import '../models/livestream_model.dart';
import '../models/voting_candidate_model.dart';

class LivestreamRemoteDataSource {
  final Dio dio;
  LivestreamRemoteDataSource(this.dio);

  Future<LivestreamModel> getLivestream(String livestreamId) async {
    try {
      final response = await dio.get('/api/livestreams/$livestreamId');
      return LivestreamModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch livestream: $e');
    }
  }

  Future<List<CommentModel>> getComments(String livestreamId) async {
    try {
      final response = await dio.get('/api/livestreams/$livestreamId/comments');
      final data = response.data['data'] as List? ?? [];
      return data.map((c) => CommentModel.fromJson(c)).toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<CommentModel> sendComment(String livestreamId, String message) async {
    try {
      final response = await dio.post(
        '/api/livestreams/$livestreamId/comments',
        data: {'message': message},
      );
      return CommentModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to send comment: $e');
    }
  }

  Future<List<VotingCandidateModel>> getVotingCandidates(
    String livestreamId,
  ) async {
    try {
      final response = await dio.get('/api/livestreams/$livestreamId/voting');
      final data = response.data['data'] as List? ?? [];
      return data.map((c) => VotingCandidateModel.fromJson(c)).toList();
    } catch (e) {
      throw Exception('Failed to fetch voting candidates: $e');
    }
  }

  Future<void> vote(String livestreamId, String candidateId) async {
    try {
      await dio.post(
        '/api/livestreams/$livestreamId/vote',
        data: {'candidate_id': candidateId},
      );
    } catch (e) {
      throw Exception('Failed to vote: $e');
    }
  }
}
