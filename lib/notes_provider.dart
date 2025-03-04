import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:urban_tutor/config.dart';
import 'package:urban_tutor/data/notes_data.dart';
import 'package:urban_tutor/models/notes_model.dart';
import 'package:urban_tutor/notes_manager.dart';

class NotesProvider with ChangeNotifier {
  final NotesManager _notesManager = NotesManager.instance;
  final Map<String, List<Map<String, dynamic>>> _dummyNotesByGrade = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NotesProvider() {
    for (var note in notesData) {
      String grade = note['grade'] ?? '0';
      _dummyNotesByGrade.putIfAbsent(grade, () => []);
      _dummyNotesByGrade[grade]!.add(note);
    }
  }

Future<void> addNote({
  required String title,
  required String description,
  required String subject,
  required String difficulty,
  required String grade,
  required String schoolName,
  required String uploaderName,
  required int fileSize,
  required PlatformFile platformFile,
}) async {
  try {
    _isLoading = true;
    notifyListeners();

    final uri = Uri.parse(uploadNote);
    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'title': title,
      'description': description,
      'subject': subject,
      'difficulty': difficulty,
      'grade': grade,
      'schoolName': schoolName,
      'uploaderName': uploaderName,
      'fileSize': fileSize.toString(),
    });

    if (kIsWeb) {
      if (platformFile.bytes == null) throw Exception('No file data');
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        platformFile.bytes!,
        filename: platformFile.name,
      ));
    } else {
      final file = File(platformFile.path!);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: basename(file.path),
      ));
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Request timed out'),
    );

    final response = await http.Response.fromStream(streamedResponse);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw HttpException('Upload failed with status: ${response.statusCode}');
    }

    final jsonResponse = json.decode(response.body);

    // Extract the note data from the 'data' field
    final noteData = jsonResponse['data'];
    if (noteData == null) {
      throw Exception('Backend response is missing required fields');
    }

    final newNote = Note(
      id: noteData['_id'] ?? DateTime.now().toString(),
      title: noteData['title'],
      description: noteData['description'],
      downloadedAt: DateTime.parse(noteData['createdAt']),
      type: NoteType.pdf,
      subject: noteData['subject'],
      size: noteData['fileSize'],
      grade: noteData['grade'],
      schoolName: noteData['schoolName'],
      uploaderName: noteData['uploaderName'],
      difficulty: noteData['difficulty'],
      pages: noteData['pages'] ?? 10,
      downloads: noteData['downloads'] ?? 0,
      icon: _getSubjectIcon(noteData['subject']),
    );

    _notesManager.addNote(grade, newNote);
    notifyListeners();

    print('Note uploaded and added successfully.');
  } catch (e) {
    print('Error uploading note: $e');
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> fetchNotes({
    required String grade,
    String? subject,
    String? difficulty,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$getNotesByGrade/$grade'));

      if (response.statusCode == 200) {
        final List<dynamic> notesData = json.decode(response.body);

        for (var noteData in notesData) {
          final note = Note(
            id: noteData['_id'],
            title: noteData['title'],
            description: noteData['description'],
            downloadedAt: DateTime.parse(noteData['createdAt']),
            type: NoteType.pdf,
            subject: noteData['subject'],
            size: noteData['fileSize'],
            grade: noteData['grade'],
            schoolName: noteData['schoolName'],
            uploaderName: noteData['uploaderName'],
            difficulty: noteData['difficulty'],
            pages: noteData['pages'] ?? 10,
            downloads: noteData['downloads'] ?? 0,
            icon: _getSubjectIcon(noteData['subject']),
          );
          _notesManager.addNote(grade, note);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching notes: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> filterNotesForGrade({
    required String grade,
    required String subject,
    required String difficulty,
    required String searchQuery,
  }) {
    List<Map<String, dynamic>> gradeSpecificDummyNotes =
        _dummyNotesByGrade[grade] ?? [];
    List<Note> gradeSpecificUploadedNotes =
        _notesManager.getNotesForGrade(grade);

    List<Map<String, dynamic>> allNotes = [
      ...gradeSpecificDummyNotes,
      ...gradeSpecificUploadedNotes.map((note) => {
            'title': note.title,
            'subject': note.subject,
            'difficulty': note.difficulty,
            'pages': note.pages,
            'downloads': note.downloads,
            'icon': note.icon,
            'grade': note.grade,
            'description': note.description,
            'schoolName': note.schoolName,
            'uploaderName': note.uploaderName,
            'size': note.size,
            'id': note.id,
          })
    ];

    return allNotes.where((note) {
      bool matchesSubject = subject == 'All' || note['subject'] == subject;
      bool matchesDifficulty =
          difficulty == 'All' || note['difficulty'] == difficulty;
      bool matchesSearch = searchQuery.isEmpty ||
          note['title']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      return matchesSubject && matchesDifficulty && matchesSearch;
    }).toList();
  }

  Future<void> downloadNote(String noteId) async {
    try {
      await http
          .post(Uri.parse('$incrementDownloads/$noteId/increment-downloads'));

      final response =
          await http.get(Uri.parse('$downloadNote/$noteId/download'));

      if (response.statusCode == 200) {
        if (kIsWeb) {
          // Web download handling would go here
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/$noteId.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        }
      } else {
        throw HttpException(
            'Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading note: $e');
      rethrow;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.book;
      case 'marathi':
        return Icons.language;
      case 'hindi':
        return Icons.translate;
      case 'french':
        return Icons.language;
      case 'sanskrit':
        return Icons.auto_stories;
      case 'geography':
        return Icons.public;
      case 'social studies':
        return Icons.history_edu;
      default:
        return Icons.notes;
    }
  }
}
