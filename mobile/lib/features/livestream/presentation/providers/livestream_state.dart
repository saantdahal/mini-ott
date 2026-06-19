import "../../domain/entities/comment.dart";
import "../../domain/entities/livestream.dart";
import "../../domain/entities/voting_candidate.dart";

enum LivestreamActionType { load, sendComment, vote, none }

class LivestreamState {
  final Livestream? livestream;
  final List<Comment> comments;
  final List<VotingCandidate> votingCandidates;
  final bool isLoading;
  final bool sendingComment;
  final String? errorMessage;
  final LivestreamActionType actionType;

  const LivestreamState({
    this.livestream,
    this.comments = const [],
    this.votingCandidates = const [],
    this.isLoading = false,
    this.sendingComment = false,
    this.errorMessage,
    this.actionType = LivestreamActionType.none,
  });

  LivestreamState copyWith({
    Livestream? livestream,
    List<Comment>? comments,
    List<VotingCandidate>? votingCandidates,
    bool? isLoading,
    bool? sendingComment,
    String? errorMessage,
    LivestreamActionType? actionType,
  }) {
    return LivestreamState(
      livestream: livestream ?? this.livestream,
      comments: comments ?? this.comments,
      votingCandidates: votingCandidates ?? this.votingCandidates,
      isLoading: isLoading ?? this.isLoading,
      sendingComment: sendingComment ?? this.sendingComment,
      errorMessage: errorMessage ?? this.errorMessage,
      actionType: actionType ?? this.actionType,
    );
  }
}
