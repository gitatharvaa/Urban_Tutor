// lib/services/notes_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../models/note_model.dart';
import 'cloudinary_service.dart';

class NotesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String notesCollection = 'notes';
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'];

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Upload note with file
  static Future<String> uploadNote({
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
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Validate file
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception('File size exceeds 50MB limit');
      }

      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception('File type not supported. Allowed: ${allowedExtensions.join(', ')}');
      }

      // Upload file to Cloudinary
      final fileUrl = await CloudinaryService.upload(
        file,
        folder: 'urban_tutor/notes/$category/$grade',
        isRaw: true,
      );

      // Create note model
      final note = NoteModel(
        fileName: title.isNotEmpty ? title : fileName,
        fileUrl: fileUrl,
        fileType: fileExtension,
        fileSizeBytes: fileSize,
        uploadedBy: user.uid,
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: category,
        description: description.isNotEmpty ? description : null,
        tags: [...tags, category.toLowerCase(), 'grade-$grade', difficulty.toLowerCase()],
        grade: grade,
        difficulty: difficulty,
        isPublic: isPublic,
      );

      // Save to Firestore
      final docRef = await _firestore.collection(notesCollection).add(note.toFirestore());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to upload note: ${e.toString()}');
    }
  }

  // Add note without file (text-only note)
  static Future<String> addTextNote({
    required String title,
    required String description,
    required String category,
    required String grade,
    required String difficulty,
    List<String> tags = const [],
    bool isPublic = true,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      final note = NoteModel(
        fileName: title,
        fileUrl: '',
        fileType: 'text',
        fileSizeBytes: description.length,
        uploadedBy: user.uid,
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: category,
        description: description,
        tags: [...tags, category.toLowerCase(), 'grade-$grade', difficulty.toLowerCase()],
        grade: grade,
        difficulty: difficulty,
        isPublic: isPublic,
      );

      final docRef = await _firestore.collection(notesCollection).add(note.toFirestore());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add note: ${e.toString()}');
    }
  }

  // OPTIMIZED: Get notes with simplified queries to avoid index requirements
  static Stream<List<NoteModel>> getNotesStream({
    String? grade,
    String? category,
    String? difficulty,
    String? userId,
    bool publicOnly = true,
    int limit = 100,
  }) {
    try {
      // Base query - only essential filters to minimize index requirements
      Query query = _firestore.collection(notesCollection)
          .where('isActive', isEqualTo: true);

      if (publicOnly) {
        query = query.where('isPublic', isEqualTo: true);
      }

      if (userId != null) {
        query = query.where('uploadedBy', isEqualTo: userId);
      }

      // Simple ordering by uploadedAt (this should work with basic indexing)
      query = query.orderBy('uploadedAt', descending: true).limit(limit);

      return query.snapshots().map((snapshot) {
        var notes = snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
        
        // Apply additional filters locally to avoid complex indexes
        if (grade != null && grade != 'All') {
          notes = notes.where((note) => note.grade == grade).toList();
        }

        if (category != null && category != 'All') {
          notes = notes.where((note) => note.category == category).toList();
        }

        if (difficulty != null && difficulty != 'All') {
          notes = notes.where((note) => 
              note.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
        }

        return notes;
      });
    } catch (e) {
      // Return empty stream on error
      return Stream.value(<NoteModel>[]);
    }
  }

  // OPTIMIZED: Get notes as future with simplified queries
  static Future<List<NoteModel>> getNotes({
    String? grade,
    String? category,
    String? difficulty,
    String? userId,
    bool publicOnly = true,
    int limit = 100,
  }) async {
    try {
      // Base query - minimal filters
      Query query = _firestore.collection(notesCollection)
          .where('isActive', isEqualTo: true);

      if (publicOnly) {
        query = query.where('isPublic', isEqualTo: true);
      }

      if (userId != null) {
        query = query.where('uploadedBy', isEqualTo: userId);
      }

      // Simple ordering
      query = query.orderBy('uploadedAt', descending: true).limit(limit);

      final snapshot = await query.get();
      var notes = snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
      
      // Apply filters locally
      if (grade != null && grade != 'All') {
        notes = notes.where((note) => note.grade == grade).toList();
      }

      if (category != null && category != 'All') {
        notes = notes.where((note) => note.category == category).toList();
      }

      if (difficulty != null && difficulty != 'All') {
        notes = notes.where((note) => 
            note.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
      }

      return notes;
    } catch (e) {
      print('Error fetching notes: $e');
      return <NoteModel>[]; // Return empty list on error
    }
  }

  // Get single note by ID
  static Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore.collection(notesCollection).doc(noteId).get();
      if (doc.exists) {
        return NoteModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch note: ${e.toString()}');
    }
  }

  // Update note
  static Future<void> updateNote(String noteId, Map<String, dynamic> updates) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Add updated timestamp
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      // Check if user owns the note
      final noteDoc = await _firestore.collection(notesCollection).doc(noteId).get();
      if (!noteDoc.exists) throw Exception('Note not found');

      final noteData = noteDoc.data() as Map<String, dynamic>;
      if (noteData['uploadedBy'] != user.uid) {
        throw Exception('Unauthorized to update this note');
      }

      await _firestore.collection(notesCollection).doc(noteId).update(updates);
    } catch (e) {
      throw Exception('Failed to update note: ${e.toString()}');
    }
  }

  // Delete note (soft delete)
  static Future<void> deleteNote(String noteId) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user owns the note
      final noteDoc = await _firestore.collection(notesCollection).doc(noteId).get();
      if (!noteDoc.exists) throw Exception('Note not found');

      final noteData = noteDoc.data() as Map<String, dynamic>;
      if (noteData['uploadedBy'] != user.uid) {
        throw Exception('Unauthorized to delete this note');
      }

      // Soft delete
      await _firestore.collection(notesCollection).doc(noteId).update({
        'isActive': false,
        'deletedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete note: ${e.toString()}');
    }
  }

  // SIMPLIFIED: Search notes with basic query
  static Future<List<NoteModel>> searchNotes({
    required String searchQuery,
    String? grade,
    String? category,
    String? difficulty,
    int limit = 50,
  }) async {
    try {
      // Simple query
      Query query = _firestore.collection(notesCollection)
          .where('isActive', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .orderBy('uploadedAt', descending: true)
          .limit(limit * 2); // Get more to filter locally

      final snapshot = await query.get();
      var notes = snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
      
      // Apply all filters locally
      final searchLower = searchQuery.toLowerCase();
      notes = notes.where((note) {
        bool matchesSearch = note.fileName.toLowerCase().contains(searchLower) ||
               (note.description?.toLowerCase().contains(searchLower) ?? false) ||
               note.tags.any((tag) => tag.toLowerCase().contains(searchLower));

        bool matchesGrade = grade == null || grade == 'All' || note.grade == grade;
        bool matchesCategory = category == null || category == 'All' || note.category == category;
        bool matchesDifficulty = difficulty == null || difficulty == 'All' || 
            note.difficulty.toLowerCase() == difficulty.toLowerCase();

        return matchesSearch && matchesGrade && matchesCategory && matchesDifficulty;
      }).take(limit).toList();

      return notes;
    } catch (e) {
      print('Error searching notes: $e');
      return <NoteModel>[];
    }
  }

  // Get available categories
  static Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(notesCollection)
          .where('isActive', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .get();

      final categories = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      final categoryList = categories.toList();
      categoryList.sort();
      return categoryList;
    } catch (e) {
      return ['Mathematics', 'Science', 'English', 'History']; // Fallback
    }
  }

  // Get available grades
  static Future<List<String>> getGrades() async {
    try {
      final snapshot = await _firestore.collection(notesCollection)
          .where('isActive', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .get();

      final grades = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final grade = data['grade'] as String?;
        if (grade != null && grade.isNotEmpty) {
          grades.add(grade);
        }
      }

      final gradeList = grades.toList();
      gradeList.sort();
      return gradeList;
    } catch (e) {
      return ['9', '10', '11', '12']; // Fallback
    }
  }

  // Pick file helper
  static Future<File?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result?.files.single != null) {
        final file = File(result!.files.single.path!);
        
        // Validate file size
        final fileSize = await file.length();
        if (fileSize > maxFileSizeBytes) {
          throw Exception('File size exceeds 50MB limit');
        }

        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Error picking file: ${e.toString()}');
    }
  }

  // Get user's notes count
  static Future<int> getUserNotesCount(String userId) async {
    try {
      final snapshot = await _firestore.collection(notesCollection)
          .where('uploadedBy', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
