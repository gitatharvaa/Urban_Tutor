import 'package:flutter/material.dart';
import 'filters.dart';
import 'notes_list.dart';

class NotesPage extends StatefulWidget {
  final String grade;

  const NotesPage({super.key, required this.grade});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String selectedSubject = 'All';
  String selectedDifficulty = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade ${widget.grade} Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showFilterBottomSheet(
                context: context,
                selectedDifficulty: selectedDifficulty,
                onDifficultyChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Subject Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: ['All', 'Mathematics', 'Science', 'English', 'Hindi', 'Social Studies']
                    .map((subject) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(subject),
                      selected: selectedSubject == subject,
                      onSelected: (selected) {
                        setState(() {
                          selectedSubject = selected ? subject : 'All';
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes List
          Expanded(
            child: NotesList(
              selectedSubject: selectedSubject,
              selectedDifficulty: selectedDifficulty,
              searchQuery: searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}
