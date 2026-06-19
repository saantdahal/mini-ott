import "../models/comment_model.dart";
import "../models/livestream_model.dart";
import "../models/voting_candidate_model.dart";

class MockLivestream {
  static final livestream = LivestreamModel(
    id: 'live_001',
    title: 'PULSE LIVE - Best Performance Ever',
    description: 'Watch the most insane performance with incredible lighting',
    streamer: 'PulseLive',
    streamerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=PulseLive',
    videoUrl: 'assets/livestream.mp4',
    quality: 'HD 4K',
    viewerCount: 14200,
    isLive: true,
    startedAt: DateTime.now().subtract(const Duration(hours: 2)),
    categories: ['Music', 'Performance', 'Entertainment'],
  );

  static final mockComments = [
    CommentModel(
      id: 'c1',
      userId: 'u1',
      username: 'Marcus_Vibe',
      userAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus',
      message: 'This drop is absolutely insane! The lighting is 10/10 tonight.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      likes: 342,
    ),
    CommentModel(
      id: 'c2',
      userId: 'u2',
      username: 'ElenaDesign',
      userAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Elena',
      message:
          'Did they just use that transition? Wow. I\'m voting for the next set to be Gold!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      likes: 289,
    ),
  ];

  static final votingCandidates = [
    VotingCandidateModel(
      id: 'v1',
      title: 'Gold Theme',
      votes: 4320,
      percentage: 45.5,
    ),
    VotingCandidateModel(
      id: 'v2',
      title: 'Silver Theme',
      votes: 2890,
      percentage: 30.2,
    ),
    VotingCandidateModel(
      id: 'v3',
      title: 'Neon Purple',
      votes: 1680,
      percentage: 17.6,
    ),
    VotingCandidateModel(
      id: 'v4',
      title: 'Holographic',
      votes: 630,
      percentage: 6.7,
    ),
  ];
}
