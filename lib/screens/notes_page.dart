import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  final String grade;

  const NotesPage({super.key, required this.grade});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<String> subjects = [
    'Mathematics', 
    'Science', 
    'English', 
    'Hindi', 
    'Social Studies'
  ];

  List<String> difficultyLevels = ['All', 'Easy', 'Medium', 'Advanced'];
  
  String selectedSubject = 'All';
  String selectedDifficulty = 'All';
  String searchQuery = '';

  List<Map<String, dynamic>> notesData = [
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
    // Add more dummy notes
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade ${widget.grade} Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
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
                children: subjects.map((subject) {
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

          // Notes Grid
          Expanded(
            child: filteredNotes.isEmpty
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
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Decorative Header
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  note['icon'],
                                  size: 60,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        note['subject'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getDifficultyColor(note['difficulty']),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          note['difficulty'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.pages, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('${note['pages']} Pages', style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.download, size: 16, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text('${note['downloads']}', style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Difficulty Level'),
                    DropdownButton<String>(
                      value: selectedDifficulty,
                      items: difficultyLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedDifficulty = value!;
                        });
                        setState(() {
                          selectedDifficulty = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}