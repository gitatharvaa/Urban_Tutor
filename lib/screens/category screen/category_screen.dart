import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_tutor/screens/download_notes_screen.dart';
import 'package:urban_tutor/widgets/horizontal_card_view.dart';
import 'package:urban_tutor/widgets/level_progress_card.dart';
import 'package:urban_tutor/widgets/leaderboard.dart';
import 'package:urban_tutor/widgets/quest_card.dart';
import 'package:urban_tutor/models/user_profile.dart';
import 'package:urban_tutor/models/quest.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with TickerProviderStateMixin {
  UserProfile? userProfile;
  List<Quest>? activeQuests;
  List<Map<String, dynamic>>? leaderboardData;
  
  // Animation controllers
  AnimationController? _headerAnimationController;
  AnimationController? _contentAnimationController;
  AnimationController? _pointsAnimationController;
  
  // Animations
  Animation<double>? _headerFadeAnimation;
  Animation<double>? _headerSlideAnimation;
  Animation<double>? _contentFadeAnimation;
  Animation<double>? _pointsScaleAnimation;
  Animation<Color?>? _pointsColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Header animation controller
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Content animation controller
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Points animation controller
    _pointsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController!,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _headerSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController!,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController!,
      curve: Curves.easeOut,
    ));

    _pointsScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pointsAnimationController!,
      curve: Curves.elasticOut,
    ));

    _pointsColorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.amber,
    ).animate(CurvedAnimation(
      parent: _pointsAnimationController!,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Start header animation immediately
    _headerAnimationController?.forward();
    
    // Start content animation with slight delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _contentAnimationController?.forward();
      }
    });

    // Start points animation with more delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _pointsAnimationController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController?.dispose();
    _contentAnimationController?.dispose();
    _pointsAnimationController?.dispose();
    super.dispose();
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
        baseColor: 'blue',
        accessory: 'glasses',
        background: 'space',
        isUnlocked: true,
      ),
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

  // Responsive breakpoint helpers
  bool _isTablet(double width) => width >= 600 && width < 1024;
  bool _isDesktop(double width) => width >= 1024;
  bool _isMobile(double width) => width < 600;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final theme = Theme.of(context);

    // Responsive sizing
    final bool isTablet = _isTablet(screenWidth);
    final bool isDesktop = _isDesktop(screenWidth);
    final bool isMobile = _isMobile(screenWidth);

    final double horizontalPadding = isDesktop
        ? screenWidth * 0.08
        : isTablet
            ? screenWidth * 0.05
            : screenWidth * 0.04;

    final double verticalSpacing = isDesktop
        ? screenHeight * 0.03
        : isTablet
            ? screenHeight * 0.025
            : screenHeight * 0.02;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildEnhancedAppBar(context, screenWidth, screenHeight, theme),
      body: SafeArea(
        child: _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
                child: _buildBody(
                    context, horizontalPadding, verticalSpacing, screenWidth, screenHeight, theme),
              )
            : _buildBody(
                context, horizontalPadding, verticalSpacing, screenWidth, screenHeight, theme),
      ),
    );
  }

  PreferredSize _buildEnhancedAppBar(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    ThemeData theme,
  ) {
    final bool isDesktop = _isDesktop(screenWidth);
    final bool isTablet = _isTablet(screenWidth);

    final double appBarHeight = isDesktop
        ? screenHeight * 0.10
        : isTablet
            ? screenHeight * 0.09
            : screenHeight * 0.08;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: _headerFadeAnimation != null && _headerSlideAnimation != null
              ? FadeTransition(
                  opacity: _headerFadeAnimation!,
                  child: Transform.translate(
                    offset: Offset(0, _headerSlideAnimation!.value),
                    child: _buildAppBarTitle(screenWidth),
                  ),
                )
              : _buildAppBarTitle(screenWidth),
          actions: [_buildAppBarActions(screenWidth, theme)],
        ),
      ),
    );
  }

  Widget _buildAppBarLeading(double screenWidth, ThemeData theme) {
    final bool isDesktop = _isDesktop(screenWidth);
    final bool isTablet = _isTablet(screenWidth);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          Icons.grid_view_rounded,
          color: Colors.white,
          size: isDesktop ? 28 : isTablet ? 26 : 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildAppBarTitle(double screenWidth) {
    final bool isDesktop = _isDesktop(screenWidth);
    final bool isTablet = _isTablet(screenWidth);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            FontAwesomeIcons.layerGroup,
            color: Colors.white,
            size: isDesktop ? 24 : isTablet ? 22 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Categories',
          style: GoogleFonts.raleway(
            fontSize: isDesktop ? 28 : isTablet ? 26 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarActions(double screenWidth, ThemeData theme) {
    final bool isDesktop = _isDesktop(screenWidth);
    final bool isTablet = _isTablet(screenWidth);

    return Container(
      margin: EdgeInsets.only(right: screenWidth * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : isTablet ? 14 : 12,
        vertical: isDesktop ? 10 : isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pointsScaleAnimation != null && _pointsColorAnimation != null
              ? ScaleTransition(
                  scale: _pointsScaleAnimation!,
                  child: AnimatedBuilder(
                    animation: _pointsColorAnimation!,
                    builder: (context, child) {
                      return Icon(
                        Icons.star_rounded,
                        color: _pointsColorAnimation!.value ?? Colors.amber,
                        size: isDesktop ? 24 : isTablet ? 22 : 20,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: isDesktop ? 24 : isTablet ? 22 : 20,
                ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            userProfile?.totalPoints.toString() ?? '0',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double horizontalPadding,
    double verticalSpacing,
    double screenWidth,
    double screenHeight,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced Notes Section
          _buildEnhancedNotesSection(
              context, verticalSpacing, screenWidth, theme),

          // Horizontal Card View with enhanced styling
          _buildEnhancedHorizontalCardSection(verticalSpacing),

          // Enhanced Level Progress
          _buildEnhancedLevelProgressSection(verticalSpacing),

          // Enhanced Active Quests
          _buildEnhancedActiveQuestsSection(verticalSpacing, screenWidth),

          // Enhanced Leaderboard
          _buildEnhancedLeaderboardSection(verticalSpacing),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: verticalSpacing * 3),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEnhancedNotesSection(
    BuildContext context,
    double verticalSpacing,
    double screenWidth,
    ThemeData theme,
  ) {
    final bool isDesktop = _isDesktop(screenWidth);
    final bool isTablet = _isTablet(screenWidth);

    return SliverToBoxAdapter(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: verticalSpacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const NotesScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: FadeTransition(
                                  opacity: animation, child: child),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(
                          isDesktop ? 32 : isTablet ? 24 : 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Notes',
                                  style: GoogleFonts.raleway(
                                    color: Colors.white,
                                    fontSize: isDesktop
                                        ? 28
                                        : isTablet
                                            ? 24
                                            : 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(
                                    height: isDesktop ? 12 : isTablet ? 10 : 8),
                                Text(
                                  'Access your study materials and notes',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isDesktop
                                        ? 16
                                        : isTablet
                                            ? 14
                                            : 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(
                                isDesktop ? 20 : isTablet ? 16 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              FontAwesomeIcons.bookOpen,
                              color: Colors.white,
                              size: isDesktop ? 32 : isTablet ? 28 : 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildEnhancedHorizontalCardSection(double verticalSpacing) {
    return SliverToBoxAdapter(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.only(bottom: verticalSpacing),
                child: const HorizontalCardView(),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildEnhancedLevelProgressSection(double verticalSpacing) {
    return SliverToBoxAdapter(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1200),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.only(bottom: verticalSpacing),
                child: userProfile != null
                    ? LevelProgressCard(
                        level: userProfile!.level,
                        currentExp: userProfile!.currentExp,
                        expToNextLevel: userProfile!.expToNextLevel,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedActiveQuestsSection(
      double verticalSpacing, double screenWidth) {
    final bool isDesktop = _isDesktop(screenWidth);
    final bool isTablet = _isTablet(screenWidth);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(-30 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: EdgeInsets.only(bottom: verticalSpacing),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : isTablet ? 16 : 12,
                      vertical: isDesktop ? 12 : isTablet ? 10 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.trophy,
                          color: Colors.blue,
                          size: isDesktop ? 20 : isTablet ? 18 : 16,
                        ),
                        SizedBox(width: isDesktop ? 12 : isTablet ? 10 : 8),
                        Text(
                          'Active Quests',
                          style: GoogleFonts.raleway(
                            fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Quest Cards
          if (activeQuests != null)
            ...activeQuests!.asMap().entries.map((entry) {
              final index = entry.key;
              final quest = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 1000 + (index * 200)),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        margin: EdgeInsets.only(bottom: verticalSpacing),
                        child: QuestCard(
                          quest: quest,
                          onTap: () {
                            // Handle quest tap with feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Quest "${quest.title}" selected!',
                                  style: GoogleFonts.inter(),
                                ),
                                backgroundColor: Colors.blue,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEnhancedLeaderboardSection(double verticalSpacing) {
    return SliverToBoxAdapter(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1400),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: verticalSpacing),
                child: leaderboardData != null
                    ? LeaderboardCard(leaderboardData: leaderboardData!)
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}