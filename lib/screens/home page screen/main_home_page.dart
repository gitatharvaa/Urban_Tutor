import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:urban_tutor/main_drawer.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'package:urban_tutor/providers/auth_provider.dart';
import 'package:urban_tutor/providers/tutor_provider.dart';
import 'package:urban_tutor/screens/add_tutor_profile_page.dart';
import 'package:urban_tutor/screens/login_screen.dart';
import 'package:urban_tutor/screens/teacher_detail_page.dart';
import 'package:urban_tutor/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Tutors', style: TextStyle(color: AppColors.primaryBlue)),
          content: const Text('Advanced filtering functionality coming soon!'),
          actions: [
            TextButton(
              child: Text('Close', style: TextStyle(color: AppColors.primaryBlue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fabSize = screenWidth < 600 ? 56.0 : 72.0;
    final double fabIconSize = screenWidth < 600 ? 24.0 : 32.0;

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
            drawer: ResponsiveMainDrawer(
              onSelectedScreen: _setScreen,
            ),
            appBar: _buildAppBar(),
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
                  FontAwesomeIcons.chalkboardUser,
                  semanticLabel: 'Add tutor profile',
                  size: fabIconSize,
                  color: Colors.white,
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: CustomScrollView(
                  slivers: [
                    _buildHeader(),
                    _buildSearchBar(),
                    _buildTeacherList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Urban Tutor',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Find Your Perfect Tutor',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, subject, or location...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterTutors,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _openFilterDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTeacherList() {
    return SliverToBoxAdapter(
      child: Consumer<TutorProvider>(
        builder: (context, tutorProvider, child) {
          if (tutorProvider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (tutorProvider.filteredTutors.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tutors found',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Text(
                        'Try adjusting your search criteria',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tutorProvider.filteredTutors.length,
            itemBuilder: (context, index) {
              final tutor = tutorProvider.filteredTutors[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherDetailPage(tutor: tutor),
                      ),
                    );
                  },
                  child: _buildTutorCard(tutor),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTutorCard(TutorModel tutor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildTutorImage(tutor.personalInfo.profileImageUrl),
                const SizedBox(width: 16),
                _buildTutorInfo(tutor),
              ],
            ),
            if (_hasSocialMedia(tutor.socialMedia)) ...[
              const SizedBox(height: 16),
              const Divider(thickness: 0.5, height: 10),
              const SizedBox(height: 8),
              _buildSocialMediaButtons(tutor.socialMedia),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTutorImage(String? imageUrl) {
    return Container(
      width: 85,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.background,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primaryBlue,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.background,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
            : Container(
                color: AppColors.background,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.primaryBlue,
                ),
              ),
      ),
    );
  }

  Widget _buildTutorInfo(TutorModel tutor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tutor.personalInfo.fullName,
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            Icons.location_on,
            '${tutor.location.area}, ${tutor.location.city}',
            AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          _buildDetailRow(
            Icons.school,
            tutor.professionalInfo.qualification,
            AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          _buildDetailRow(
            Icons.subject,
            tutor.professionalInfo.subjects.take(2).join(', ') +
                (tutor.professionalInfo.subjects.length > 2 ? '...' : ''),
            AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          _buildDetailRow(
            Icons.currency_rupee,
            '₹${tutor.professionalInfo.monthlyRate.toInt()}/month',
            AppColors.primaryGreen,
          ),
          if (tutor.ratings.totalReviews > 0) ...[
            const SizedBox(height: 4),
            _buildRatingRow(tutor.ratings.averageRating, tutor.ratings.totalReviews),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(double rating, int totalReviews) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: 4),
        Text(
          '${rating.toStringAsFixed(1)} ($totalReviews reviews)',
          style: TextStyle(fontSize: 12, color: AppColors.textLight),
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

  Widget _buildSocialMediaButtons(SocialMediaInfo socialMedia) {
    List<Widget> buttons = [];

    if (socialMedia.whatsapp.isNotEmpty) {
      buttons.add(
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 28),
          onPressed: () => _launchUrl('https://wa.me/${socialMedia.whatsapp}'),
        ),
      );
    }

    if (socialMedia.facebook.isNotEmpty) {
      buttons.add(
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 28),
          onPressed: () => _launchUrl(socialMedia.facebook.startsWith('http') 
              ? socialMedia.facebook 
              : 'https://facebook.com/${socialMedia.facebook}'),
        ),
      );
    }

    if (socialMedia.instagram.isNotEmpty) {
      buttons.add(
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F), size: 28),
          onPressed: () => _launchUrl('https://www.instagram.com/${socialMedia.instagram}'),
        ),
      );
    }

    if (socialMedia.twitter.isNotEmpty) {
      buttons.add(
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black, size: 28),
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
      print('Could not launch $url: $e');
    }
  }
}
