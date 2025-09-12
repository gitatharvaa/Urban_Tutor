// lib/widgets/filters/rating_filter_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_provider.dart';
import '../../utils/app_colors.dart';

class RatingFilterSection extends StatelessWidget {
  const RatingFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Minimum Rating', Icons.star, isTablet),
            const SizedBox(height: 12),
            
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  _buildRatingOption(
                    i.toDouble(),
                    filterProvider.currentFilter.minRating,
                    (rating) => filterProvider.setMinRating(rating),
                    isTablet,
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'Selected: ${filterProvider.currentFilter.minRating == 0 ? 'Any rating' : '${filterProvider.currentFilter.minRating.toInt()}+ stars'}',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppColors.textSecondary,
              ),
            ),
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

  Widget _buildRatingOption(
    double rating,
    double currentRating,
    ValueChanged<double> onChanged,
    bool isTablet,
  ) {
    final isSelected = currentRating >= rating;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(rating),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: isSelected ? Colors.white : Colors.amber,
                    size: isTablet ? 18 : 16,
                  ),
                  Text(
                    '${rating.toInt()}+',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

