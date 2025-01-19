class UserProfile {
  final String id;
  final String name;
  final int level;
  final int currentExp;
  final int expToNextLevel;
  final int totalPoints;
  final List<String> achievements;
  final AvatarCustomization avatar;
  final int rank;
  final int streakDays;

  UserProfile({
    required this.id,
    required this.name,
    required this.level,
    required this.currentExp,
    required this.expToNextLevel,
    required this.totalPoints,
    required this.achievements,
    required this.avatar,
    required this.rank,
    required this.streakDays,
  });
}

class AvatarCustomization {
  final String baseColor;
  final String accessory;
  final String background;
  final bool isUnlocked;

  AvatarCustomization({
    required this.baseColor,
    required this.accessory,
    required this.background,
    required this.isUnlocked,
  });
}