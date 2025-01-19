import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_tutor/data/dummy_teacher_data.dart';
import 'package:urban_tutor/main_drawer.dart';
import 'package:urban_tutor/screens/teacher_detail_page.dart';
import 'package:urban_tutor/screens/add_tutor_profile_page.dart'; // Add this import
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  String _searchQuery = '';
  late List<Map<String, dynamic>> _filteredTeachers;

  final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6A5ACD),
    primary: const Color(0xFF6A5ACD),
    secondary: const Color(0xFFFF6B6B),
    background: const Color(0xFFF4F4F8),
    surface: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _filteredTeachers = dummyTeacherData;
  }

  void _filterTeachers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTeachers = query.isEmpty
          ? dummyTeacherData
          : dummyTeacherData
              .where((teacher) => teacher['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
    });
  }

  void _setScreen(String identifier) {
    // Handle screen changes here
    switch (identifier) {
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

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Tutors',
              style: TextStyle(color: _colorScheme.primary)),
          content: const Text('Filter functionality coming soon!'),
          actions: [
            TextButton(
              child: Text('Close',
                  style: TextStyle(color: _colorScheme.secondary)),
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
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculate FAB size based on screen dimensions
    final double fabSize = screenWidth < 600 ? 56.0 : 72.0;
    final double fabIconSize = screenWidth < 600 ? 24.0 : 32.0;

    return Theme(
      data: ThemeData(
        colorScheme: _colorScheme,
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: _colorScheme.background,
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
            backgroundColor: _colorScheme.secondary,
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
      ),
    );
  }


   PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 53, 69), 
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: Material.defaultSplashRadius,),
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
              color: _colorScheme.primary),
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
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: Icon(Icons.search, color: _colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterTeachers,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _colorScheme.secondary,
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

  SliverList _buildTeacherList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final teacher = _filteredTeachers[index];
          final teacherMap =
              teacher.map((key, value) => MapEntry(key, value.toString()));

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeacherDetailPage(teacher: teacherMap),
                  ),
                );
              },
              child: _buildTeacherCard(teacher),
            ),
          );
        },
        childCount: _filteredTeachers.length,
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildTeacherImage(teacher['imageUrl']),
                const SizedBox(width: 16),
                _buildTeacherInfo(teacher),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 0.5, height: 10, indent: 5, endIndent: 5,),
            const SizedBox(height: 5),
            _buildSocialMediaButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherImage(String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          imageUrl ?? '',
          width: 85,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person, size: 85, color: _colorScheme.primary),
        ),
      ),
    );
  }

Widget _buildTeacherInfo(Map<String, dynamic> teacher) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            teacher['name'] ?? '',
            style: GoogleFonts.raleway(  // Professional, modern sans-serif for headings
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),  // Slightly increased spacing
        _buildDetailRow(
          Icons.location_on, 
          teacher['location'] ?? '',
          Colors.black,
          textStyle: GoogleFonts.sourceSans3(  // Clean, readable sans-serif for body text
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        _buildDetailRow(
          Icons.school,
          "Qualification: ${teacher['qualification'] ?? ''}",
          Colors.black,
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        _buildDetailRow(
          Icons.subject,
          "Subject: ${teacher['subject'] ?? ''}",
          Colors.black,
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}



  Widget _buildSocialMediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green,size: 30,),
          onPressed: () async {
            const url =
                'whatsapp://send?phone=+1234567890';
            if (await canLaunchUrl(url as Uri)) {
              await launchUrl(url as Uri);
            }
          },
        ),
        const SizedBox(width: 33),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 30,),
          onPressed: () async {
            const url = 'https://facebook.com/profile';
            if (await canLaunchUrl(url as Uri)) {
              await launchUrl(url as Uri);
            }
          },
        ),
        const SizedBox(width: 33),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.instagram,
          size: 30,
              color: Color(0xFFE4405F)),
          onPressed: () async {
            final Uri url = Uri.parse('instagram://user?username=USERNAME');
            final Uri webUrl = Uri.parse('https://www.instagram.com/USERNAME');
            try {
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (await canLaunchUrl(webUrl)) {
                  await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                }
              }
            } catch (e) {
              print('Could not launch Instagram');
            }
          },
        ),
        const SizedBox(width: 33),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xTwitter,
          size: 30,
              color: Colors.black),
          onPressed: () async {
            final Uri url = Uri.parse('twitter://user?screen_name=USERNAME');
            final Uri webUrl = Uri.parse('https://twitter.com/USERNAME');
            try {
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (await canLaunchUrl(webUrl)) {
                  await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                }
              }
            } catch (e) {
              print('Could not launch Twitter');
            }
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color iconColor, {TextStyle? textStyle}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}