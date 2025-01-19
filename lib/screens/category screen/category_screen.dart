import 'package:flutter/material.dart';
import 'package:urban_tutor/screens/download_notes_screen.dart';
import 'package:urban_tutor/widgets/horizontal_card_view.dart';
import 'package:urban_tutor/widgets/level_progress_card.dart';
import 'package:urban_tutor/widgets/leaderboard.dart';
import 'package:urban_tutor/widgets/quest_card.dart';
import 'package:urban_tutor/models/user_profile.dart';
import 'package:urban_tutor/models/quest.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late UserProfile userProfile;
  late List<Quest> activeQuests;
  late List<Map<String, dynamic>> leaderboardData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

void _initializeData() {
    userProfile = UserProfile(
        id: '1',
        name: 'John Doe',
        level: 5,
        currentExp: 450,
        expToNextLevel: 1000,
        totalPoints: 2500,
        achievements: ['Math Master', 'Science Explorer'],
        rank: 3,
        streakDays: 7,
        avatar: AvatarCustomization(
            baseColor: 'blue',  // Add your desired color
            accessory: 'glasses',  // Add your desired accessory
            background: 'space',  // Add your desired background
            isUnlocked: true  // Set unlock status
        )
    );

    activeQuests = [
      Quest(
        id: '1',
        title: 'Complete Math Quiz',
        description: 'Solve 10 algebra problems',
        rewardPoints: 100,
        rewardExp: 50,
        type: QuestType.daily,
        subject: SubjectType.math,
        deadline: DateTime.now().add(const Duration(hours: 3)),
        progress: 0.7,
        rewards: ['Math Badge', '2x XP Boost'],
      ),
      Quest(
        id: '2',
        title: 'Read Science Article',
        description: 'Read and summarize the article',
        rewardPoints: 150,
        rewardExp: 75,
        type: QuestType.subject,
        subject: SubjectType.science,
        deadline: DateTime.now().add(const Duration(hours: 5)),
        progress: 0.3,
        rewards: ['Science Explorer Badge'],
      ),
    ];

    leaderboardData = [
      {'name': 'Alice', 'points': 3000, 'isUser': false},
      {'name': 'Bob', 'points': 2800, 'isUser': false},
      {'name': 'John Doe', 'points': 2500, 'isUser': true},
      {'name': 'Emma', 'points': 2300, 'isUser': false},
      {'name': 'David', 'points': 2100, 'isUser': false},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalSpacing = screenHeight * 0.02;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.08),
        child: AppBar(
          title: Text(
            'Categories',
            style: TextStyle(fontSize: screenWidth * 0.05),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: horizontalPadding),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    userProfile.totalPoints.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: CustomScrollView(
            slivers: [
              // Notes Section with Navigation
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: verticalSpacing),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotesScreen(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.7),
                            theme.colorScheme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Notes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.notes,
                              color: Colors.white,
                              size: screenWidth * 0.07,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

               // Horizontal Card View
              const SliverToBoxAdapter(child: HorizontalCardView()),

              // Level Progress
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: verticalSpacing),
                  child: LevelProgressCard(
                    level: userProfile.level,
                    currentExp: userProfile.currentExp,
                    expToNextLevel: userProfile.expToNextLevel,
                  ),
                ),
              ),

              // Active Quests
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: verticalSpacing),
                  child: Text(
                    'Active Quests',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: verticalSpacing),
                    child: QuestCard(
                      quest: activeQuests[index],
                      onTap: () {
                        // Handle quest tap
                      },
                    ),
                  ),
                  childCount: activeQuests.length,
                ),
              ),

              // Leaderboard
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: verticalSpacing),
                  child: LeaderboardCard(leaderboardData: leaderboardData),
                ),
              ),

              // Collectibles
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: verticalSpacing),
              //     child: CollectiblesGrid(
              //       collectibles: collectibles,
              //       onCollectibleTap: (collectible) {
              //         // Handle collectible tap
              //       },
              //     ),
              //   ),
              // ),

              // Avatar Customization
              //SliverToBoxAdapter(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: verticalSpacing),
              //     child: AvatarCustomizer(
              //       avatarData: userProfile.avatar,
              //       onColorChange: (color) {
              //         // Handle color change
              //       },
              //       onAccessoryChange: (accessory) {
              //         // Handle accessory change
              //       },
              //       onBackgroundChange: (background) {
              //         // Handle background change
              //       },
              //     ),
              //   ),
              // ),


              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: verticalSpacing * 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}