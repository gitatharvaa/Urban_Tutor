// lib/widgets/filters/subject_filter_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_provider.dart';
import '../../utils/app_colors.dart';

class SubjectFilterSection extends StatelessWidget {
  const SubjectFilterSection({super.key});

  static const List<String> availableSubjects = [
    'Mathematics', 'Science', 'English', 'Hindi', 'Physics', 
    'Chemistry', 'Biology', 'History', 'Geography', 'Economics',
    'Computer Science', 'Accounts', 'Social Studies', 'Sanskrit',
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
            _buildSectionHeader('Subjects', Icons.subject, isTablet),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableSubjects.map((subject) {
                final isSelected = filterProvider.currentFilter.selectedSubjects.contains(subject);
                return _buildSubjectChip(
                  subject,
                  isSelected,
                  () => filterProvider.toggleSubject(subject),
                  isTablet,
                );
              }).toList(),
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

  Widget _buildSubjectChip(
    String subject,
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
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          subject,
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
