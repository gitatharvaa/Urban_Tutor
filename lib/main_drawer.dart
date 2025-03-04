import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_tutor/auth/login_screen.dart';
import 'package:urban_tutor/services/auth_service.dart';

class ResponsiveMainDrawer extends StatelessWidget {
  const ResponsiveMainDrawer({
    super.key,
    required this.onSelectedScreen,
  });

    void _logout(BuildContext context) async {
    try {
      // Remove the token using AuthService
      await AuthService.logout();
      
      if (context.mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Show error message if logout fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error logging out. Please try again.'),
            backgroundColor: Colors.red,
            duration:  Duration(seconds: 3),
          ),
        );
      }
    }
  }

  final void Function(String identifier) onSelectedScreen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ResponsiveScale scale = _calculateResponsiveScale(constraints);

        return Drawer(
          backgroundColor: const Color.fromARGB(255, 27, 42, 61),
          child: Column(
            children: [
              _buildDrawerHeader(context, scale),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.person,
                        title: 'Profile',
                        onTap: () {
                          onSelectedScreen('profile');
                          Navigator.pop(context);
                        },
                        scale: scale,
                      ),
                      _buildDivider(),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.schedule,
                        title: 'Schedule',
                        onTap: () {
                          onSelectedScreen('schedule');
                          Navigator.pop(context);
                        },
                        scale: scale,
                      ),
                      _buildDivider(),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () {
                          onSelectedScreen('settings');
                          Navigator.pop(context);
                        },
                        scale: scale,
                      ),
                      _buildDivider(),
                    ],
                  ),
                ),
              ),
              _buildDivider(),
              _buildLogoutButton(context, scale),
              const SizedBox(height: 20), // Add some spacing at the bottom
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: const Color.fromARGB(255, 196, 209, 225).withOpacity(0.2),
        height: 1,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ResponsiveScale scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.logout,
          size: scale.iconSize,
          color: const Color.fromARGB(255, 196, 209, 225),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.montserrat(
            fontSize: scale.titleFontSize,
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(255, 196, 209, 225),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => _logout(context),
      ),
    );
  }

  ResponsiveScale _calculateResponsiveScale(BoxConstraints constraints) {
    double width = constraints.maxWidth;

    if (width < 320) {
      return const ResponsiveScale(
        iconSize: 18,
        titleFontSize: 14,
        headerIconSize: 30,
        headerTitleFontSize: 18,
      );
    } else if (width < 375) {
      return const ResponsiveScale(
        iconSize: 22,
        titleFontSize: 16,
        headerIconSize: 40,
        headerTitleFontSize: 20,
      );
    } else if (width < 600) {
      return const ResponsiveScale(
        iconSize: 24,
        titleFontSize: 18,
        headerIconSize: 45,
        headerTitleFontSize: 22,
      );
    } else if (width < 1024) {
      return const ResponsiveScale(
        iconSize: 30,
        titleFontSize: 22,
        headerIconSize: 55,
        headerTitleFontSize: 26,
      );
    } else {
      return const ResponsiveScale(
        iconSize: 32,
        titleFontSize: 24,
        headerIconSize: 60,
        headerTitleFontSize: 28,
      );
    }
  }

  Widget _buildDrawerHeader(BuildContext context, ResponsiveScale scale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 178, 34, 34), // Darker red
            Color.fromARGB(255, 220, 53, 69), // Lighter red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,  // Changed to a book icon to represent tutoring
              size: scale.headerIconSize,
              color: Colors.white,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Urban Tutor',
                  style: GoogleFonts.montserrat(
                    fontSize: scale.headerTitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ResponsiveScale scale,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          size: scale.iconSize,
          color: const Color.fromARGB(255, 196, 209, 225),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: scale.titleFontSize,
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(255, 196, 209, 225),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}

class ResponsiveScale {
  final double iconSize;
  final double titleFontSize;
  final double headerIconSize;
  final double headerTitleFontSize;

  const ResponsiveScale({
    required this.iconSize,
    required this.titleFontSize,
    required this.headerIconSize,
    required this.headerTitleFontSize,
  });
}