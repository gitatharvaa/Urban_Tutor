// lib/widgets/filters/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../utils/app_colors.dart';
import 'subject_filter_section.dart';
import 'location_filter_section.dart';
import 'price_range_section.dart';
import 'rating_filter_section.dart';
import 'experience_filter_section.dart';
import 'standards_filter_section.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive dimensions
    final isTablet = screenWidth > 768;
    final maxHeight = screenHeight * (isTablet ? 0.8 : 0.9);
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(horizontalPadding, isTablet),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SubjectFilterSection(),
                      const SizedBox(height: 24),
                      const LocationFilterSection(),
                      const SizedBox(height: 24),
                      const PriceRangeSection(),
                      const SizedBox(height: 24),
                      const ExperienceFilterSection(),
                      const SizedBox(height: 24),
                      const RatingFilterSection(),
                      const SizedBox(height: 24),
                      const StandardsFilterSection(),
                      const SizedBox(height: 100), // Bottom padding for buttons
                    ],
                  ),
                ),
              ),
              
              // Bottom action buttons
              _buildBottomActions(horizontalPadding, filterProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(double horizontalPadding, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Text(
            'Filter Tutors',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Consumer<FilterProvider>(
            builder: (context, filterProvider, child) {
              final count = filterProvider.activeFilterCount;
              if (count > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(double horizontalPadding, FilterProvider filterProvider) {
    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                filterProvider.clearAllFilters();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters
                context.read<TutorProvider>().applyFilters(filterProvider.currentFilter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
