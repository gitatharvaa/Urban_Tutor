import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData;

  const LeaderboardCard({
    Key? key,
    required this.leaderboardData,
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
          Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          ...List.generate(
            leaderboardData.length,
            (index) => _buildLeaderboardItem(
              context,
              index + 1,
              leaderboardData[index]['name'],
              leaderboardData[index]['points'],
              leaderboardData[index]['isUser'],
              screenWidth,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    int rank,
    String name,
    int points,
    bool isUser,
    double screenWidth,
    ThemeData theme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: isUser ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.08,
            height: screenWidth * 0.08,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.grey[300]!;
    }
  }
}