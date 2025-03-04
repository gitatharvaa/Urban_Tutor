import 'package:flutter/material.dart';
import '../models/quest.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onTap;

  const QuestCard({
    super.key,
    required this.quest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildQuestTypeIcon(quest.type, quest.subject),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    quest.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              quest.description,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: quest.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(quest.type)),
                minHeight: screenWidth * 0.015,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: screenWidth * 0.04,
                      color: Colors.amber,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      '${quest.rewardPoints} points',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.flash_on,
                      size: screenWidth * 0.04,
                      color: theme.primaryColor,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      '${quest.rewardExp} XP',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                _buildTimeRemaining(quest.deadline),
              ],
            ),
            if (quest.rewards.isNotEmpty) ...[
              SizedBox(height: screenWidth * 0.02),
              Wrap(
                spacing: screenWidth * 0.02,
                children: quest.rewards
                    .map((reward) => _buildRewardBadge(reward, screenWidth))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestTypeIcon(QuestType type, SubjectType? subject) {
    IconData icon;
    Color color;

    switch (type) {
      case QuestType.daily:
        icon = Icons.calendar_today;
        color = Colors.blue;
        break;
      case QuestType.weekly:
        icon = Icons.date_range;
        color = Colors.purple;
        break;
      case QuestType.subject:
        icon = _getSubjectIcon(subject!);
        color = _getSubjectColor(subject);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  IconData _getSubjectIcon(SubjectType subject) {
    switch (subject) {
      case SubjectType.math:
        return Icons.calculate;
      case SubjectType.science:
        return Icons.science;
      case SubjectType.language:
        return Icons.language;
      case SubjectType.history:
        return Icons.history_edu;
      case SubjectType.geography:
        return Icons.public;
    }
  }

  Color _getSubjectColor(SubjectType subject) {
    switch (subject) {
      case SubjectType.math:
        return Colors.blue;
      case SubjectType.science:
        return Colors.green;
      case SubjectType.language:
        return Colors.orange;
      case SubjectType.history:
        return Colors.brown;
      case SubjectType.geography:
        return Colors.teal;
    }
  }

  Color _getProgressColor(QuestType type) {
    switch (type) {
      case QuestType.daily:
        return Colors.blue;
      case QuestType.weekly:
        return Colors.purple;
      case QuestType.subject:
        return Colors.green;
    }
  }

  Widget _buildTimeRemaining(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Text(
      hours > 0 ? '${hours}h ${minutes}m left' : '${minutes}m left',
      style: TextStyle(
        color: hours < 2 ? Colors.red : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildRewardBadge(String reward, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        reward,
        style: TextStyle(
          fontSize: screenWidth * 0.03,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}