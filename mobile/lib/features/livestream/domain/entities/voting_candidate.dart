class VotingCandidate {
  final String id;
  final String title;
  final int votes;
  final double percentage;
  final bool isSelected;

  const VotingCandidate({
    required this.id,
    required this.title,
    required this.votes,
    required this.percentage,
    this.isSelected = false,
  });

  VotingCandidate copyWith({
    String? id,
    String? title,
    int? votes,
    double? percentage,
    bool? isSelected,
  }) {
    return VotingCandidate(
      id: id ?? this.id,
      title: title ?? this.title,
      votes: votes ?? this.votes,
      percentage: percentage ?? this.percentage,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
