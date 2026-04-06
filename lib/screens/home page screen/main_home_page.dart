// lib/screens/main_home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:urban_tutor/main_drawer.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'package:urban_tutor/providers/auth_provider.dart';
import 'package:urban_tutor/providers/tutor_provider.dart';
import 'package:urban_tutor/providers/filter_provider.dart';
import 'package:urban_tutor/screens/add_tutor_profile_page.dart';
import 'package:urban_tutor/screens/login_screen.dart';
import 'package:urban_tutor/screens/teacher_detail_page.dart';
import 'package:urban_tutor/utils/app_colors.dart';
import 'package:urban_tutor/widgets/filters/filter_bottom_sheet.dart';
import 'package:urban_tutor/widgets/filters/quick_filter_chips.dart';
import 'package:url_launcher/url_launcher.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TutorProvider>(context, listen: false).loadTutors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTutors(String query) {
    setState(() {
      _searchQuery = query;
    });
    Provider.of<TutorProvider>(context, listen: false).filterTutors(query);
  }

  void _setScreen(String identifier) {
    switch (identifier) {
      case 'logout':
        _handleLogout();
        break;
      case 'profile':
        // Handle profile screen
        break;
      case 'schedule':
        // Handle schedule screen
        break;
      case 'settings':
        // Handle settings screen
        break;
    }
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _openAdvancedFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    final horizontalPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 16.0;
    final fabSize = isDesktop ? 72.0 : isTablet ? 64.0 : 56.0;
    final fabIconSize = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;

    return Theme(
      data: ThemeData(
        colorScheme: AppColors.educationalColorScheme,
        useMaterial3: true,
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }
          return Scaffold(
            backgroundColor: AppColors.background,
            drawer: isPhone ? ResponsiveMainDrawer(onSelectedScreen: _setScreen) : null,
            appBar: _buildAppBar(isPhone, isTablet, isDesktop),
            floatingActionButton: SizedBox(
              width: fabSize,
              height: fabSize,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTutorProfilePage(),
                    ),
                  );
                },
                backgroundColor: AppColors.primaryBlue,
                child: Icon(
                  FontAwesomeIcons.chalkboardUser as IconData?,
                  semanticLabel: 'Add tutor profile',
                  size: fabIconSize,
                  color: Colors.white,
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: SafeArea(
              child: Row(
                children: [
                  // Side navigation for desktop/tablet
                  if (!isPhone)
                    Container(
                      width: 280,
                      child: ResponsiveMainDrawer(onSelectedScreen: _setScreen),
                    ),
                  
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: CustomScrollView(
                        slivers: [
                          _buildHeader(isTablet, isDesktop),
                          _buildSearchAndFilterBar(isTablet, isDesktop),
                          _buildQuickFilters(),
                          _buildActiveFiltersDisplay(isTablet, isDesktop),
                          _buildTeacherList(isTablet, isDesktop),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSize _buildAppBar(bool isPhone, bool isTablet, bool isDesktop) {
    final titleFontSize = isDesktop ? 28.0 : isTablet ? 24.0 : 20.0;
    
    return PreferredSize(
      preferredSize: Size.fromHeight(isDesktop ? 70.0 : 60.0),
      child: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: isPhone ? Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu, 
              color: Colors.white, 
              size: isDesktop ? 28 : 24,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ) : null,
        automaticallyImplyLeading: isPhone,
        title: Text(
          'Urban Tutor',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: isPhone,
        actions: [
          if (!isPhone) ...[
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: isDesktop ? 28 : 24,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
                size: isDesktop ? 28 : 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(bool isTablet, bool isDesktop) {
    final titleFontSize = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;
    final subtitleFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your Perfect Tutor',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<TutorProvider>(
              builder: (context, tutorProvider, child) {
                return Text(
                  '${tutorProvider.filteredTutors.length} tutors available',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchAndFilterBar(bool isTablet, bool isDesktop) {
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: fontSize),
                decoration: InputDecoration(
                  hintText: 'Search by name, subject, or location...',
                  hintStyle: TextStyle(fontSize: fontSize),
                  prefixIcon: Icon(
                    Icons.search, 
                    color: AppColors.primaryBlue,
                    size: isDesktop ? 24 : 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : 16,
                    vertical: isDesktop ? 16 : 12,
                  ),
                ),
                onChanged: _filterTutors,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
                onPressed: _openAdvancedFilterDialog,
                iconSize: isDesktop ? 28 : 24,
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildQuickFilters() {
    return const SliverToBoxAdapter(
      child: QuickFilterChips(),
    );
  }

  SliverToBoxAdapter _buildActiveFiltersDisplay(bool isTablet, bool isDesktop) {
    return SliverToBoxAdapter(
      child: Consumer<FilterProvider>(
        builder: (context, filterProvider, child) {
          if (!filterProvider.hasActiveFilters) {
            return const SizedBox.shrink();
          }
          
          return Container(
            margin: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Active Filters:',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        filterProvider.clearAllFilters();
                        context.read<TutorProvider>().applyFilters(filterProvider.currentFilter);
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: isDesktop ? 14 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...filterProvider.currentFilter.selectedSubjects.map(
                      (subject) => _buildActiveFilterChip(
                        subject,
                        () => filterProvider.toggleSubject(subject),
                        isTablet,
                      ),
                    ),
                    ...filterProvider.currentFilter.selectedLocations.map(
                      (location) => _buildActiveFilterChip(
                        location,
                        () => filterProvider.toggleLocation(location),
                        isTablet,
                      ),
                    ),
                    if (!filterProvider.currentFilter.priceRange.isDefault)
                      _buildActiveFilterChip(
                        '₹${filterProvider.currentFilter.priceRange.min.toInt()}-₹${filterProvider.currentFilter.priceRange.max.toInt()}',
                        () => filterProvider.setPriceRange(0, 50000),
                        isTablet,
                      ),
                    if (filterProvider.currentFilter.minRating > 0)
                      _buildActiveFilterChip(
                        '${filterProvider.currentFilter.minRating.toInt()}+ stars',
                        () => filterProvider.setMinRating(0),
                        isTablet,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove, bool isTablet) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 12 : 11,
          color: AppColors.primaryBlue,
        ),
      ),
      onDeleted: onRemove,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
      deleteIconColor: AppColors.primaryBlue,
      side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
    );
  }

  SliverToBoxAdapter _buildTeacherList(bool isTablet, bool isDesktop) {
    return SliverToBoxAdapter(
      child: Consumer<TutorProvider>(
        builder: (context, tutorProvider, child) {
          if (tutorProvider.isLoading) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 64.0 : 32.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: isDesktop ? 64 : 48,
                      height: isDesktop ? 64 : 48,
                      child: const CircularProgressIndicator(),
                    ),
                    SizedBox(height: isDesktop ? 24 : 16),
                    Text(
                      'Finding the best tutors for you...',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (tutorProvider.filteredTutors.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 64.0 : 32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: isDesktop ? 80 : 64,
                      color: AppColors.textLight,
                    ),
                    SizedBox(height: isDesktop ? 24 : 16),
                    Text(
                      'No tutors found',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 12 : 8),
                    Text(
                      _searchQuery.isNotEmpty 
                          ? 'Try adjusting your search criteria or filters'
                          : 'No tutors match your current filters',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 32 : 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        context.read<FilterProvider>().clearAllFilters();
                        context.read<TutorProvider>().applyFilters(
                          context.read<FilterProvider>().currentFilter,
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 20,
                          vertical: isDesktop ? 16 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // Responsive grid/list layout
          if (isDesktop) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.2,
              ),
              itemCount: tutorProvider.filteredTutors.length,
              itemBuilder: (context, index) {
                final tutor = tutorProvider.filteredTutors[index];
                return GestureDetector(
                  onTap: () => _navigateToTutorDetails(tutor),
                  child: _buildTutorCard(tutor, isTablet, isDesktop),
                );
              },
            );
          } else if (isTablet) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: tutorProvider.filteredTutors.length,
              itemBuilder: (context, index) {
                final tutor = tutorProvider.filteredTutors[index];
                return GestureDetector(
                  onTap: () => _navigateToTutorDetails(tutor),
                  child: _buildTutorCard(tutor, isTablet, isDesktop),
                );
              },
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tutorProvider.filteredTutors.length,
              itemBuilder: (context, index) {
                final tutor = tutorProvider.filteredTutors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => _navigateToTutorDetails(tutor),
                    child: _buildTutorCard(tutor, isTablet, isDesktop),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToTutorDetails(TutorModel tutor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherDetailPage(tutor: tutor),
      ),
    );
  }

  Widget _buildTutorCard(TutorModel tutor, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 16.0 : 12.0;
    final profileImageDiameter = isDesktop ? 130.0 : isTablet ? 120.0 : 110.0;
    final bodyFontSize = isDesktop ? 16.0 : isTablet ? 14.0 : 13.0;
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final gapSize = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: isDesktop ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Stack(
          children: [
            // Large circular profile image positioned on left top with gap
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: profileImageDiameter / 2,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  backgroundImage: tutor.personalInfo.profileImageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(tutor.personalInfo.profileImageUrl)
                      : null,
                  child: tutor.personalInfo.profileImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: profileImageDiameter * 0.6,
                          color: AppColors.primaryBlue,
                        )
                      : null,
                ),
              ),
            ),
            // Rectangular card with tutor details positioned with gap from circular image
            Positioned(
              left: profileImageDiameter + gapSize,
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.background,
                      AppColors.primaryBlue.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isDesktop ? 18 : 14),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.personalInfo.fullName,
                      style: GoogleFonts.raleway(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isDesktop ? 12 : 10),
                    _buildDetailRow(
                      Icons.location_on,
                      '${tutor.location.area}, ${tutor.location.city}',
                      AppColors.textSecondary,
                      bodyFontSize * 0.9,
                    ),
                    SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.school,
                      tutor.professionalInfo.qualification,
                      AppColors.textSecondary,
                      bodyFontSize * 0.9,
                    ),
                    SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.subject,
                      tutor.professionalInfo.subjects.take(2).join(', ') +
                          (tutor.professionalInfo.subjects.length > 2 ? '...' : ''),
                      AppColors.textSecondary,
                      bodyFontSize * 0.9,
                    ),
                    SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.currency_rupee,
                      '₹${tutor.professionalInfo.monthlyRate.toInt()}/month',
                      AppColors.primaryGreen,
                      bodyFontSize,
                    ),
                    if (tutor.ratings.totalReviews > 0) ...[
                      SizedBox(height: 6),
                      _buildRatingRow(tutor.ratings.averageRating, tutor.ratings.totalReviews, bodyFontSize * 0.8),
                    ],
                    SizedBox(height: isDesktop ? 12 : 10),
                    if (_hasSocialMedia(tutor.socialMedia))
                      _buildSocialMediaButtons(tutor.socialMedia, isDesktop),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color, double fontSize) {
    return Row(
      children: [
        Icon(icon, size: fontSize + 2, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(double rating, int totalReviews, double fontSize) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: fontSize + 2,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${rating.toStringAsFixed(1)} ($totalReviews reviews)',
            style: TextStyle(fontSize: fontSize, color: AppColors.textLight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  bool _hasSocialMedia(SocialMediaInfo socialMedia) {
    return socialMedia.whatsapp.isNotEmpty ||
           socialMedia.facebook.isNotEmpty ||
           socialMedia.instagram.isNotEmpty ||
           socialMedia.twitter.isNotEmpty;
  }

  Widget _buildSocialMediaButtons(SocialMediaInfo socialMedia, bool isDesktop) {
    List<Widget> buttons = [];
    final iconSize = isDesktop ? 20.0 : 18.0;
    
    if (socialMedia.whatsapp.isNotEmpty) {
      buttons.add(
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: iconSize),
          onPressed: () => _launchUrl('https://wa.me/${socialMedia.whatsapp}'),
        ),
      );
    }
    if (socialMedia.facebook.isNotEmpty) {
      buttons.add(
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: iconSize),
          onPressed: () => _launchUrl(socialMedia.facebook.startsWith('http') 
              ? socialMedia.facebook 
              : 'https://facebook.com/${socialMedia.facebook}'),
        ),
      );
    }
    if (socialMedia.instagram.isNotEmpty) {
      buttons.add(
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: FaIcon(FontAwesomeIcons.instagram, color: const Color(0xFFE4405F), size: iconSize),
          onPressed: () => _launchUrl('https://www.instagram.com/${socialMedia.instagram}'),
        ),
      );
    }
    if (socialMedia.twitter.isNotEmpty) {
      buttons.add(
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black, size: iconSize),
          onPressed: () => _launchUrl('https://twitter.com/${socialMedia.twitter}'),
        ),
      );
    }
    if (buttons.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }

  void _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}
