import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "../../domain/entities/voting_candidate.dart";

class VotingBubble extends StatelessWidget {
  final VotingCandidate candidate;
  final bool isSelected;
  final VoidCallback onVote;
  final bool isLoading;

  const VotingBubble({
    super.key,
    required this.candidate,
    required this.isSelected,
    required this.onVote,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onVote,
          borderRadius: BorderRadius.circular(14.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.10)
                  : colorScheme.surfaceContainer,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        candidate.title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isLoading)
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${candidate.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Stack(
                    children: [
                      Container(
                        height: 8.h,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      FractionallySizedBox(
                        widthFactor: (candidate.percentage / 100).clamp(
                          0.0,
                          1.0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          height: 8.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [
                                      colorScheme.primary,
                                      colorScheme.primary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ]
                                  : [
                                      colorScheme.secondary,
                                      colorScheme.secondary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 13.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${candidate.votes} votes',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: colorScheme.primary,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Your vote',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
