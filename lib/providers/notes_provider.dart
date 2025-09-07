// lib/providers/notes_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';

class NotesProvider with ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedGrade = 'All';
  String _selectedSubject = 'All';
  String _selectedDifficulty = 'All';
  String _searchQuery = '';
  StreamSubscription<List<NoteModel>>? _notesSubscription;

  // Getters
  List<NoteModel> get notes => _notes;
  List<NoteModel> get filteredNotes => _applyAllFilters();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedGrade => _selectedGrade;
  String get selectedSubject => _selectedSubject;
  String get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }

  // Apply all filters and return filtered list
  List<NoteModel> _applyAllFilters() {
    var filtered = List<NoteModel>.from(_notes);

    // Grade filter
    if (_selectedGrade != 'All') {
      filtered = filtered.where((note) => note.grade == _selectedGrade).toList();
    }

    // Subject filter
    if (_selectedSubject != 'All') {
      filtered = filtered.where((note) => note.category == _selectedSubject).toList();
    }

    // Difficulty filter
    if (_selectedDifficulty != 'All') {
      filtered = filtered.where((note) => 
          note.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase()).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        return note.fileName.toLowerCase().contains(searchLower) ||
               (note.description?.toLowerCase().contains(searchLower) ?? false) ||
               note.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();
    }

    // Sort by upload date (newest first)
    filtered.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    return filtered;
  }

  // Fetch notes from backend
  Future<void> fetchNotes({
    String? grade,
    String? subject,
    String? difficulty,
    bool useStream = false,
    bool forceRefresh = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Update current filters
      if (grade != null) _selectedGrade = grade;
      if (subject != null) _selectedSubject = subject;
      if (difficulty != null) _selectedDifficulty = difficulty;

      if (useStream && !forceRefresh) {
        // Use real-time stream
        _notesSubscription?.cancel();
        _notesSubscription = NotesService.getNotesStream(
          grade: _selectedGrade == 'All' ? null : _selectedGrade,
          category: _selectedSubject == 'All' ? null : _selectedSubject,
          difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
        ).listen(
          (notes) {
            _notes = notes;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
      } else {
        // One-time fetch - get all notes and filter locally
        _notes = await NotesService.getNotes();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load notes (alias for fetchNotes)
  Future<void> loadNotes(String category) async {
    await fetchNotes(subject: category);
  }

  // Add note with file upload
  Future<void> uploadNote({
    required File file,
    required String title,
    required String description,
    required String category,
    required String grade,
    required String difficulty,
    List<String> tags = const [],
    bool isPublic = true,
  }) async {
    try {
      _errorMessage = null;

      final noteId = await NotesService.uploadNote(
        file: file,
        title: title,
        description: description,
        category: category,
        grade: grade,
        difficulty: difficulty,
        tags: tags,
        isPublic: isPublic,
      );

      // Fetch the newly created note and add it to the list immediately
      final newNote = await NotesService.getNoteById(noteId);
      if (newNote != null) {
        _notes.insert(0, newNote); // Add to beginning of list
        notifyListeners();
      }

      // Small delay to ensure backend consistency
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Refresh from backend to ensure full sync
      await refreshNotes();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Add text-only note
  Future<void> addNote({
    required String title,
    required String description,
    required String grade,
    required String subject,
    required String difficulty,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
  }) async {
    try {
      _errorMessage = null;

      final noteId = await NotesService.addTextNote(
        title: title,
        description: description,
        category: subject,
        grade: grade,
        difficulty: difficulty,
      );

      // Fetch the newly created note and add it to the list immediately
      final newNote = await NotesService.getNoteById(noteId);
      if (newNote != null) {
        _notes.insert(0, newNote); // Add to beginning of list
        notifyListeners();
      }

      // Small delay to ensure backend consistency
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Refresh from backend to ensure full sync
      await refreshNotes();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      await NotesService.deleteNote(noteId);
      
      // Remove from local list immediately
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search notes
  void searchNotes(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter methods
  void setGrade(String grade) {
    _selectedGrade = grade;
    notifyListeners();
  }

  void setSubject(String subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void clearFilters() {
    _selectedGrade = 'All';
    _selectedSubject = 'All';
    _selectedDifficulty = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  // Get available options from backend
  Future<List<String>> getAvailableGrades() async {
    try {
      final grades = await NotesService.getGrades();
      final allGrades = ['All', ...grades];
      return allGrades.toSet().toList(); // Remove duplicates
    } catch (e) {
      return ['All', '9', '10', '11', '12']; // Fallback
    }
  }

  Future<List<String>> getAvailableSubjects() async {
    try {
      final subjects = await NotesService.getCategories();
      final allSubjects = ['All', ...subjects];
      return allSubjects.toSet().toList(); // Remove duplicates
    } catch (e) {
      return ['All', 'Mathematics', 'Science', 'English', 'History']; // Fallback
    }
  }

  List<String> getAvailableDifficulties() {
    return ['All', 'Easy', 'Medium', 'Hard'];
  }

  // Refresh notes
  Future<void> refreshNotes() async {
    await fetchNotes(
      grade: _selectedGrade,
      subject: _selectedSubject,
      difficulty: _selectedDifficulty,
      forceRefresh: true,
    );
  }

  // Get notes for specific grade
  List<NoteModel> getNotesForGrade(String grade) {
    if (grade == 'All') return _notes;
    return _notes.where((note) => note.grade == grade).toList();
  }
}
