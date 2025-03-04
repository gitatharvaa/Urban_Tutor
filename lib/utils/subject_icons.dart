import 'package:flutter/material.dart';

Map<String, IconData> subjectIcons = {
  'Mathematics': Icons.calculate,
  'Science': Icons.science,
  'English': Icons.book,
  'Marathi': Icons.language,
  'Hindi': Icons.language,
  'French': Icons.language,
  'Sanskrit': Icons.language,
  'Geography': Icons.public,
  'Social Studies': Icons.people
};

IconData getSubjectIcon(String subject) {
  return subjectIcons[subject] ?? Icons.note; // Default icon if subject not found
}