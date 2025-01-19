import 'package:flutter/material.dart';
import 'note_card.dart';

class NotesList extends StatelessWidget {
  final String selectedSubject;
  final String selectedDifficulty;
  final String searchQuery;

  final List<Map<String, dynamic>> notesData = [
    {
      'title': 'Algebra Basics',
      'subject': 'Mathematics',
      'difficulty': 'Easy',
      'pages': 15,
      'downloads': 250,
      'icon': Icons.calculate
    },
    {
      'title': 'Chemical Reactions',
      'subject': 'Science',
      'difficulty': 'Medium',
      'pages': 22,
      'downloads': 180,
      'icon': Icons.science
    },
    {
      'title': 'Shakespeare Summary',
      'subject': 'English',
      'difficulty': 'Advanced',
      'pages': 30,
      'downloads': 120,
      'icon': Icons.book
    },
  ];

  NotesList({
    super.key,
    required this.selectedSubject,
    required this.selectedDifficulty,
    required this.searchQuery,
  });

  List<Map<String, dynamic>> get filteredNotes {
    return notesData.where((note) {
      final matchesSubject = selectedSubject == 'All' || note['subject'] == selectedSubject;
      final matchesDifficulty = selectedDifficulty == 'All' || note['difficulty'] == selectedDifficulty;
      final matchesSearch = note['title'].toLowerCase().contains(searchQuery.toLowerCase());

      return matchesSubject && matchesDifficulty && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return filteredNotes.isEmpty
        ? const Center(child: Text('No notes found'))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return NoteCard(note: note);
            },
          );
  }
}
