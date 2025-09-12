// lib/widgets/filters/quick_filter_chips.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../utils/app_colors.dart';

class QuickFilterChips extends StatelessWidget {
  const QuickFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Responsive breakpoints
    final isPhone = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive dimensions
    final chipHeight = isDesktop ? 50.0 : isTablet ? 45.0 : 40.0;
    final horizontalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final iconSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final fontSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    
    return Container(
      height: chipHeight + 16, // Extra padding for container
      margin: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildQuickFilterChip(
            context,
            'All Tutors',
            Icons.people_outline,
            'all',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'Nearby',
            Icons.location_on_outlined,
            'nearby',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'Affordable',
            Icons.currency_rupee,
            'affordable',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'Experienced',
            Icons.workspace_premium_outlined,
            'experienced',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'Top Rated',
            Icons.star_outline,
            'top_rated',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'Online',
            Icons.video_call_outlined,
            'online',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'Mathematics',
            Icons.calculate_outlined,
            'mathematics',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'Science',
            Icons.science_outlined,
            'science',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          _buildQuickFilterChip(
            context,
            'English',
            Icons.menu_book_outlined,
            'english',
            iconSize,
            fontSize,
            chipHeight,
            isDesktop,
          ),
          // Add some padding at the end
          SizedBox(width: horizontalPadding),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    String filterType,
    double iconSize,
    double fontSize,
    double chipHeight,
    bool isDesktop,
  ) {
    return Consumer2<FilterProvider, TutorProvider>(
      builder: (context, filterProvider, tutorProvider, child) {
        final isSelected = _isFilterSelected(filterProvider, filterType);
        final isActive = isSelected || (filterType == 'all' && !filterProvider.hasActiveFilters);
        
        return GestureDetector(
          onTap: () => _handleFilterTap(context, filterProvider, tutorProvider, filterType),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: chipHeight,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 12,
              vertical: isDesktop ? 12 : 8,
            ),
            decoration: BoxDecoration(
              gradient: isActive
                  ? _getFilterGradient(filterType, context)
                  : null,
              color: isActive ? null : Colors.white,
              borderRadius: BorderRadius.circular(chipHeight / 2),
              border: Border.all(
                color: isActive 
                    ? Colors.transparent
                    : Colors.grey.shade300,
                width: isActive ? 0 : 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _getFilterColor(filterType, context).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: isActive ? Colors.white : _getFilterColor(filterType, context),
                ),
                SizedBox(width: isDesktop ? 8 : 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : Colors.grey[800],
                  ),
                ),
                // Show count badge if filter has results
                if (isActive && filterType != 'all') ...[
                  SizedBox(width: isDesktop ? 8 : 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${tutorProvider.filteredTutors.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize * 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getFilterColor(String filterType, BuildContext context) {
    final theme = Theme.of(context);
    
    switch (filterType) {
      case 'all':
        return theme.colorScheme.primary;
      case 'nearby':
        return Colors.green;
      case 'affordable':
        return Colors.blue;
      case 'experienced':
        return Colors.purple;
      case 'top_rated':
        return Colors.amber[700]!;
      case 'online':
        return Colors.indigo;
      case 'mathematics':
        return Colors.red;
      case 'science':
        return Colors.teal;
      case 'english':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }

  LinearGradient _getFilterGradient(String filterType, BuildContext context) {
    final baseColor = _getFilterColor(filterType, context);
    
    return LinearGradient(
      colors: [
        baseColor,
        baseColor.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  bool _isFilterSelected(FilterProvider filterProvider, String filterType) {
    switch (filterType) {
      case 'all':
        return !filterProvider.hasActiveFilters;
      case 'nearby':
        return filterProvider.currentFilter.selectedLocations.isNotEmpty;
      case 'affordable':
        return filterProvider.currentFilter.priceRange.max <= 10000 && 
               !filterProvider.currentFilter.priceRange.isDefault;
      case 'experienced':
        return filterProvider.currentFilter.experienceRange.min >= 5 ||
               filterProvider.currentFilter.minRating >= 4.0;
      case 'top_rated':
        return filterProvider.currentFilter.minRating >= 4.5;
      case 'online':
        // You can implement online teaching filter logic here
        return false; // Placeholder
      case 'mathematics':
        return filterProvider.currentFilter.selectedSubjects.contains('Mathematics');
      case 'science':
        return filterProvider.currentFilter.selectedSubjects.contains('Science');
      case 'english':
        return filterProvider.currentFilter.selectedSubjects.contains('English');
      default:
        return false;
    }
  }

  void _handleFilterTap(
    BuildContext context,
    FilterProvider filterProvider,
    TutorProvider tutorProvider,
    String filterType,
  ) {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Applying ${_getFilterLabel(filterType)} filter...'),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: _getFilterColor(filterType, context),
      ),
    );

    switch (filterType) {
      case 'all':
        filterProvider.clearAllFilters();
        break;
      case 'nearby':
        filterProvider.clearAllFilters();
        // You can implement location-based logic here
        // For now, we'll just show a message
        _showFeatureComingSoon(context, 'Location-based search');
        return;
      case 'affordable':
        filterProvider.clearAllFilters();
        filterProvider.setPriceRange(0, 10000);
        break;
      case 'experienced':
        filterProvider.clearAllFilters();
        filterProvider.setExperienceRange(5, 30);
        filterProvider.setMinRating(4.0);
        break;
      case 'top_rated':
        filterProvider.clearAllFilters();
        filterProvider.setMinRating(4.5);
        break;
      case 'online':
        filterProvider.clearAllFilters();
        // You can implement online teaching filter here
        _showFeatureComingSoon(context, 'Online teaching filter');
        return;
      case 'mathematics':
        filterProvider.clearAllFilters();
        filterProvider.setSubjects(['Mathematics']);
        break;
      case 'science':
        filterProvider.clearAllFilters();
        filterProvider.setSubjects(['Science']);
        break;
      case 'english':
        filterProvider.clearAllFilters();
        filterProvider.setSubjects(['English']);
        break;
    }

    // Apply the filter to tutor provider
    tutorProvider.applyFilters(filterProvider.currentFilter);
  }

  String _getFilterLabel(String filterType) {
    switch (filterType) {
      case 'all':
        return 'All Tutors';
      case 'nearby':
        return 'Nearby';
      case 'affordable':
        return 'Affordable';
      case 'experienced':
        return 'Experienced';
      case 'top_rated':
        return 'Top Rated';
      case 'online':
        return 'Online';
      case 'mathematics':
        return 'Mathematics';
      case 'science':
        return 'Science';
      case 'english':
        return 'English';
      default:
        return filterType;
    }
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('$feature coming soon!')),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
