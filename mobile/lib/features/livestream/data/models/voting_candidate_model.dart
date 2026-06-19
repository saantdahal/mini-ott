import "../../domain/entities/voting_candidate.dart";

class VotingCandidateModel extends VotingCandidate {
  const VotingCandidateModel({
    required super.id,
    required super.title,
    required super.votes,
    required super.percentage,
    super.isSelected = false,
  });

  factory VotingCandidateModel.fromJson(Map<String, dynamic> json) {
    return VotingCandidateModel(
      id: json['id'],
      title: json['title'],
      votes: json['votes'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      isSelected: json['is_selected'] ?? false,
    );
  }
}
