import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/livestream.dart';
import '../providers/livestream_providers.dart';
import '../providers/livestream_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/livestream_header.dart';
import '../widgets/livestream_tab_bar.dart';
import '../widgets/voting_bubble.dart';

class LivestreamScreen extends ConsumerStatefulWidget {
  const LivestreamScreen({super.key, this.livestreamId = 'live_001'});

  final String livestreamId;

  @override
  ConsumerState<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends ConsumerState<LivestreamScreen> {
  int selectedTabIndex = 0;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  int _lastCommentCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(livestreamNotifierProvider.notifier)
          .loadLivestream(widget.livestreamId);
      ref
          .read(livestreamNotifierProvider.notifier)
          .loadComments(widget.livestreamId);
      ref
          .read(livestreamNotifierProvider.notifier)
          .loadVoting(widget.livestreamId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  String _heroImageUrl(Livestream ls) {
    final u = ls.videoUrl.trim();
    if (u.startsWith('http')) {
      return u;
    }
    return 'https://picsum.photos/id/452/1280/720';
  }

  void _maybeScrollChatToEnd(int commentCount) {
    if (commentCount > _lastCommentCount && commentCount > 0) {
      _lastCommentCount = commentCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollController.hasClients) {
          _chatScrollController.jumpTo(
            _chatScrollController.position.maxScrollExtent,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final livestreamState = ref.watch(livestreamNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (livestreamState.livestream == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: SizedBox(
            width: 28.w,
            height: 28.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    final livestream = livestreamState.livestream!;
    _maybeScrollChatToEnd(livestreamState.comments.length);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              flex: 42,
              child: LivestreamHeader(
                heroImageUrl: _heroImageUrl(livestream),
                quality: livestream.quality,
                viewerCount: livestream.viewerCount,
                streamerName: livestream.streamer,
                streamerAvatar: livestream.streamerAvatar,
                title: livestream.title,
                onShare: () => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Share'))),
                onMore: () => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('More options'))),
              ),
            ),
            Expanded(
              flex: 58,
              child: Column(
                children: [
                  LivestreamTabBar(
                    tabs: const ['Chat', 'Vote'],
                    selectedIndex: selectedTabIndex,
                    counts: [
                      livestreamState.comments.length,
                      livestreamState.votingCandidates.length,
                    ],
                    onTabChanged: (index) =>
                        setState(() => selectedTabIndex = index),
                  ),
                  if (livestreamState.errorMessage != null)
                    Container(
                      width: double.infinity,
                      color: colorScheme.errorContainer.withValues(alpha: 0.35),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: colorScheme.error,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              livestreamState.errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error.withValues(alpha: 0.9),
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: selectedTabIndex == 0
                        ? _buildChatSection(livestreamState)
                        : _buildVotingSection(livestreamState),
                  ),
                  if (selectedTabIndex == 0) _buildChatInput(livestreamState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomePill() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.12),
                colorScheme.primary.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 12.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                'WELCOME TO THE PULSE LIVE',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String label}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainer,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 26.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection(LivestreamState livestreamState) {
    if (livestreamState.comments.isEmpty) {
      return ListView(
        controller: _chatScrollController,
        children: [
          _welcomePill(),
          SizedBox(height: 12.h),
          Center(
            child: _emptyState(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Be the first to say something',
            ),
          ),
        ],
      );
    }

    return ListView(
      controller: _chatScrollController,
      padding: EdgeInsets.only(bottom: 8.h),
      children: [
        _welcomePill(),
        ...livestreamState.comments.map((c) => ChatBubble(comment: c)),
      ],
    );
  }

  Widget _buildVotingSection(LivestreamState livestreamState) {
    if (livestreamState.votingCandidates.isEmpty) {
      return Center(
        child: _emptyState(
          icon: Icons.how_to_vote_rounded,
          label: 'No active poll right now',
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
      itemCount: livestreamState.votingCandidates.length,
      itemBuilder: (context, index) {
        final candidate = livestreamState.votingCandidates[index];
        return VotingBubble(
          candidate: candidate,
          isSelected: candidate.isSelected,
          onVote: () => ref
              .read(livestreamNotifierProvider.notifier)
              .vote(widget.livestreamId, candidate.id),
        );
      },
    );
  }

  void _handleSend(LivestreamState livestreamState) {
    if (livestreamState.sendingComment) return;
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    ref
        .read(livestreamNotifierProvider.notifier)
        .sendComment(widget.livestreamId, text);
    _commentController.clear();
  }

  Widget _buildChatInput(LivestreamState livestreamState) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        12.w,
        10.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.scrim.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _commentController,
                enabled: !livestreamState.sendingComment,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14.sp),
                cursorColor: colorScheme.primary,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(livestreamState),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Say something...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _commentController,
              builder: (context, _) {
                final hasText = _commentController.text.trim().isNotEmpty;
                final enabled = hasText && !livestreamState.sendingComment;
                return Material(
                  color: enabled
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14.r),
                  child: InkWell(
                    onTap: enabled ? () => _handleSend(livestreamState) : null,
                    borderRadius: BorderRadius.circular(14.r),
                    child: SizedBox(
                      width: 46.w,
                      height: 46.w,
                      child: livestreamState.sendingComment
                          ? Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: colorScheme.onPrimary,
                              size: 20.sp,
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
