import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../di/livestream_di.dart";
import "../../domain/usecases/get_comments_usecase.dart";
import "../../domain/usecases/get_livestream_usecase.dart";
import "../../domain/usecases/get_voting_candidates_usecase.dart";
import "../../domain/usecases/send_comment_usecase.dart";
import "../../domain/usecases/vote_usecase.dart";
import "livestream_state.dart";

class LivestreamNotifier extends Notifier<LivestreamState> {
  late final GetLivestream _getLivestream;
  late final GetComments _getComments;
  late final SendComment _sendComment;
  late final GetVotingCandidates _getVotingCandidates;
  late final Vote _vote;

  @override
  LivestreamState build() {
    _getLivestream = ref.watch(getLivestreamProvider);
    _getComments = ref.watch(getCommentsProvider);
    _sendComment = ref.watch(sendCommentProvider);
    _getVotingCandidates = ref.watch(getVotingCandidatesProvider);
    _vote = ref.watch(voteProvider);
    return const LivestreamState();
  }

  Future<void> loadLivestream(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final ls = await _getLivestream(id);
      state = state.copyWith(livestream: ls, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadComments(String id) async {
    try {
      final comments = await _getComments(id);
      state = state.copyWith(comments: comments);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> loadVoting(String id) async {
    try {
      final candidates = await _getVotingCandidates(id);
      state = state.copyWith(votingCandidates: candidates);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> sendComment(String id, String message) async {
    state = state.copyWith(sendingComment: true);
    try {
      final comment = await _sendComment(
        SendCommentParams(livestreamId: id, message: message),
      );
      final updated = [comment, ...state.comments];
      state = state.copyWith(comments: updated, sendingComment: false);
    } catch (e) {
      state = state.copyWith(sendingComment: false, errorMessage: e.toString());
    }
  }

  Future<void> vote(String id, String candidateId) async {
    try {
      await _vote(VoteParams(livestreamId: id, candidateId: candidateId));
      final updated = state.votingCandidates.map((c) {
        if (c.id == candidateId) return c.copyWith(isSelected: true);
        return c;
      }).toList();
      state = state.copyWith(votingCandidates: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
