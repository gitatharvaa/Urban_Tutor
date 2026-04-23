// lib/screens/main_home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:urban_tutor/main_drawer.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'package:urban_tutor/providers/auth_provider.dart';
import 'package:urban_tutor/providers/tutor_provider.dart';
import 'package:urban_tutor/providers/filter_provider.dart';
import 'package:urban_tutor/screens/add_tutor_profile_page.dart';
import 'package:urban_tutor/screens/login_screen.dart';
import 'package:urban_tutor/screens/teacher_detail_page.dart';
import 'package:urban_tutor/utils/app_colors.dart';
import 'package:urban_tutor/widgets/nearby_tutors_map_widget.dart';
import 'package:urban_tutor/widgets/filters/filter_bottom_sheet.dart';



class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // ── Category chip state ──
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Maths',
    'Science',
    'English',
    'SST',
    'Hindi',
    'Computer',
  ];

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

  // ─── Existing logic methods (UNTOUCHED) ───────────────────────────────────

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
        break;
      case 'schedule':
        break;
      case 'settings':
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

  void _navigateToTutorDetails(TutorModel tutor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherDetailPage(tutor: tutor),
      ),
    );
  }



  // ─── Category chip tap handler ────────────────────────────────────────────
  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = category;
    });

    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    final tutorProvider = Provider.of<TutorProvider>(context, listen: false);

    if (category == 'All') {
      filterProvider.clearAllFilters();
    } else {
      filterProvider.clearAllFilters();
      // Map chip labels to subject names used in your data
      String subjectName = category;
      if (category == 'Maths') subjectName = 'Mathematics';
      if (category == 'SST') subjectName = 'Social Studies';
      filterProvider.setSubjects([subjectName]);
    }
    tutorProvider.applyFilters(filterProvider.currentFilter);
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: ResponsiveMainDrawer(onSelectedScreen: _setScreen),
          appBar: _buildAppBar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTutorProfilePage(),
                ),
              );
            },
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 6,
            tooltip: 'Add Tutor Profile',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_add_alt_1, size: 26),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildSearchBar(),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: NearbyTutorsMapWidget(
                    onViewProfile: _navigateToTutorDetails,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                _buildCategoryLabel(),
                _buildCategoryChips(),
                _buildSectionTitle(),
                _buildTutorList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: AppColors.textPrimary, size: 26),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        'Urban Tutor',
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _openAdvancedFilterDialog,
          icon: Icon(
            Icons.tune_rounded,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ],
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterTutors,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: AppColors.textLight),
              hintText: 'Search tutors by name, subject...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  // ─── CATEGORIES LABEL ─────────────────────────────────────────────────────

  SliverToBoxAdapter _buildCategoryLabel() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Text(
          'Categories',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ─── CATEGORY CHIPS ───────────────────────────────────────────────────────

  SliverToBoxAdapter _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 0, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ..._categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _onCategoryTap(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: Color(0xFFDDDDDD), width: 1),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 16), // trailing padding
            ],
          ),
        ),
      ),
    );
  }

  // ─── SECTION TITLE ────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildSectionTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(
          'Available Tutors',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ─── TUTOR LIST ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildTutorList() {
    return SliverToBoxAdapter(
      child: Consumer<TutorProvider>(
        builder: (context, tutorProvider, child) {
          // ── Loading state ──
          if (tutorProvider.isLoading) {
            return Padding(
              padding: const EdgeInsets.all(48.0),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Finding the best tutors for you...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty state ──
          if (tutorProvider.filteredTutors.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(48.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 64, color: AppColors.textLight),
                    const SizedBox(height: 16),
                    Text(
                      'No tutors found',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Try adjusting your search criteria or filters'
                          : 'No tutors match your current filters',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        setState(() {
                          _selectedCategory = 'All';
                        });
                        context.read<FilterProvider>().clearAllFilters();
                        context.read<TutorProvider>().applyFilters(
                              context.read<FilterProvider>().currentFilter,
                            );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text('Reset Search',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Tutor cards ──
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tutorProvider.filteredTutors.length,
            itemBuilder: (context, index) {
              final tutor = tutorProvider.filteredTutors[index];
              return _buildTutorCard(tutor);
            },
          );
        },
      ),
    );
  }

  // ─── TUTOR CARD ───────────────────────────────────────────────────────────

  Widget _buildTutorCard(TutorModel tutor) {
    // Build initials for fallback avatar
    final nameParts = tutor.personalInfo.fullName.trim().split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (nameParts.isNotEmpty ? nameParts[0][0].toUpperCase() : '?');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToTutorDetails(tutor),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Profile Photo ──
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primaryBlue,
                    backgroundImage:
                        tutor.personalInfo.profileImageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(
                                tutor.personalInfo.profileImageUrl)
                            : null,
                    child: tutor.personalInfo.profileImageUrl.isEmpty
                        ? Text(
                            initials,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // ── Info Column ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name
                      Text(
                        tutor.personalInfo.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Row 2: Subject pills
                      if (tutor.professionalInfo.subjects.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: tutor.professionalInfo.subjects
                              .take(4)
                              .map((subject) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      subject,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 6),

                      // Row 3: Location
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 13, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${tutor.location.area}, ${tutor.location.city}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 4: Fees + View Profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${tutor.professionalInfo.monthlyRate.toInt()}/month',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _navigateToTutorDetails(tutor),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'View Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
