enum QuestType { daily, weekly, subject }
enum SubjectType { math, science, language, history, geography }

class Quest {
  final String id;
  final String title;
  final String description;
  final int rewardPoints;
  final int rewardExp;
  final QuestType type;
  final SubjectType? subject;
  final DateTime deadline;
  final double progress;
  final List<String> rewards;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoints,
    required this.rewardExp,
    required this.type,
    this.subject,
    required this.deadline,
    required this.progress,
    required this.rewards,
  });
}