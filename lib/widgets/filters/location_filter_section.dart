// lib/widgets/filters/location_filter_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_provider.dart';
import '../../utils/app_colors.dart';

class LocationFilterSection extends StatelessWidget {
  const LocationFilterSection({super.key});

  static const List<String> popularCities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad',
    'Pune', 'Ahmedabad', 'Surat', 'Jaipur', 'Lucknow', 'Kanpur',
    'Nagpur', 'Indore', 'Bhopal', 'Visakhapatnam', 'Pimpri-Chinchwad',
    'Patna', 'Vadodara', 'Ghaziabad',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Preferred Locations', Icons.location_on, isTablet),
            const SizedBox(height: 12),
            
            // Search for custom location
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 14 : 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  filterProvider.toggleLocation(value);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Popular cities
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: popularCities.map((city) {
                final isSelected = filterProvider.currentFilter.selectedLocations.contains(city);
                return _buildLocationChip(
                  city,
                  isSelected,
                  () => filterProvider.toggleLocation(city),
                  isTablet,
                );
              }).toList(),
            ),
            
            // Selected locations display
            if (filterProvider.currentFilter.selectedLocations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Selected Locations:',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filterProvider.currentFilter.selectedLocations.map((location) {
                  return Chip(
                    label: Text(location),
                    onDeleted: () => filterProvider.toggleLocation(location),
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: isTablet ? 12 : 11,
                    ),
                    deleteIconColor: AppColors.primaryBlue,
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isTablet) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: isTablet ? 24 : 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(
    String city,
    bool isSelected,
    VoidCallback onTap,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          city,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: isTablet ? 14 : 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
