import 'package:flutter/material.dart';
import 'package:urban_tutor/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late List<Note> notes;
  String _searchQuery = '';
  String _selectedSubject = 'All';
  NoteType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    // Simulated notes data - In real app, this would come from local storage
    notes = [
      Note(
        id: '1',
        title: 'Algebra Fundamentals',
        description: 'Basic concepts of algebra with examples',
        downloadedAt: DateTime.now().subtract(const Duration(days: 1)),
        type: NoteType.pdf,
        subject: 'Mathematics',
        size: 2 * 1024 * 1024, // 2MB
      ),
      Note(
        id: '2',
        title: 'Chemistry Lab Safety',
        description: 'Video guide on lab safety protocols',
        downloadedAt: DateTime.now().subtract(const Duration(days: 2)),
        type: NoteType.video,
        subject: 'Science',
        size: 15 * 1024 * 1024, // 15MB
        progress: 0.7,
      ),
      Note(
        id: '3',
        title: 'History Notes',
        description: 'World War II overview',
        downloadedAt: DateTime.now().subtract(const Duration(days: 3)),
        type: NoteType.document,
        subject: 'History',
        size: 1 * 1024 * 1024, // 1MB
      ),
      Note(
        id: '4',
        title: 'Biology Presentation',
        description: 'Cell structure and function',
        downloadedAt: DateTime.now().subtract(const Duration(days: 4)),
        type: NoteType.presentation,
        subject: 'Science',
        size: 5 * 1024 * 1024, // 5MB
      ),
    ];
  }

  List<Note> get filteredNotes {
    return notes.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSubject = _selectedSubject == 'All' || note.subject == _selectedSubject;
      final matchesType = _selectedType == null || note.type == _selectedType;
      return matchesSearch && matchesSubject && matchesType;
    }).toList();
  }

  void _openNote(Note note) {
    // TODO: Implement note opening functionality
    debugPrint('Opening note: ${note.title}');
  }

  void _deleteNote(Note note) {
    setState(() {
      notes.removeWhere((n) => n.id == note.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${note.title} deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isLandscape = size.width > size.height;
    final padding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Downloaded Notes',
          style: TextStyle(fontSize: screenWidth * 0.045),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          selected: _selectedType == null,
                          onSelected: (selected) {
                            setState(() => _selectedType = null);
                          },
                        ),
                        ...NoteType.values.map((type) =>
                          _buildFilterChip(
                            label: type.toString().split('.').last,
                            selected: _selectedType == type,
                            onSelected: (selected) {
                              setState(() => _selectedType = selected ? type : null);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Notes Grid/List
            Expanded(
              child: isLandscape ? _buildGridView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  Widget _buildGridView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 300).floor();
    
    return GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.02),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.5,
        crossAxisSpacing: screenWidth * 0.02,
        mainAxisSpacing: screenWidth * 0.02,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) => _buildNoteCard(filteredNotes[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) => _buildNoteListTile(filteredNotes[index]),
    );
  }

  Widget _buildNoteCard(Note note) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openNote(note),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getNoteTypeIcon(note.type),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (note.progress < 1.0) ...[
                SizedBox(height: screenWidth * 0.02),
                LinearProgressIndicator(value: note.progress),
              ],
              const Spacer(),
              Text(
                note.formattedSize,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteListTile(Note note) {
    return Dismissible(
      key: Key(note.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteNote(note),
      child: ListTile(
        leading: _getNoteTypeIcon(note.type),
        title: Text(note.title),
        subtitle: Text(note.description),
        trailing: Text(note.formattedSize),
        onTap: () => _openNote(note),
      ),
    );
  }

  Widget _getNoteTypeIcon(NoteType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NoteType.pdf:
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case NoteType.video:
        icon = Icons.video_library;
        color = Colors.blue;
        break;
      case NoteType.document:
        icon = Icons.description;
        color = Colors.green;
        break;
      case NoteType.presentation:
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      case NoteType.audio:
        icon = Icons.audiotrack;
        color = Colors.purple;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Icon(icon, color: color);
  }
}