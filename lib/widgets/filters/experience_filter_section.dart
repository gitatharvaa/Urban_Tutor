// lib/widgets/filters/experience_filter_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_tutor/models/filter_model.dart';
import '../../providers/filter_provider.dart';
import '../../utils/app_colors.dart';

class ExperienceFilterSection extends StatelessWidget {
  const ExperienceFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        final currentRange = filterProvider.currentFilter.experienceRange;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Experience (Years)', Icons.work, isTablet),
            const SizedBox(height: 16),
            
            // Experience display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentRange.min} years',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  '${currentRange.max} years',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            
            // Range slider
            RangeSlider(
              values: RangeValues(
                currentRange.min.toDouble(),
                currentRange.max.toDouble(),
              ),
              min: 0,
              max: 30,
              divisions: 30,
              activeColor: AppColors.primaryBlue,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                '${currentRange.min}y',
                '${currentRange.max}y',
              ),
              onChanged: (RangeValues values) {
                filterProvider.setExperienceRange(
                  values.start.toInt(),
                  values.end.toInt(),
                );
              },
            ),
            
            // Quick experience presets
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildPresetChip('Fresher (0-2y)', 0, 2, currentRange, filterProvider, isTablet),
                _buildPresetChip('Experienced (3-7y)', 3, 7, currentRange, filterProvider, isTablet),
                _buildPresetChip('Expert (8-15y)', 8, 15, currentRange, filterProvider, isTablet),
                _buildPresetChip('Master (15y+)', 15, 30, currentRange, filterProvider, isTablet),
              ],
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

  Widget _buildPresetChip(
    String label,
    int min,
    int max,
    ExperienceRange currentRange,
    FilterProvider filterProvider,
    bool isTablet,
  ) {
    final isSelected = currentRange.min == min && currentRange.max == max;
    
    return GestureDetector(
      onTap: () => filterProvider.setExperienceRange(min, max),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 10,
          vertical: isTablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: isTablet ? 12 : 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
