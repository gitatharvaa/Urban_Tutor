import 'package:flutter/material.dart';

class LevelProgressCard extends StatelessWidget {
  final int level;
  final int currentExp;
  final int expToNextLevel;

  const LevelProgressCard({
    Key? key,
    required this.level,
    required this.currentExp,
    required this.expToNextLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$currentExp / $expToNextLevel XP',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: currentExp / expToNextLevel,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              minHeight: screenWidth * 0.02,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            '${expToNextLevel - currentExp} XP to next level',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}