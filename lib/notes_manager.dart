// notes_manager.dart
import 'package:urban_tutor/models/notes_model.dart';

class NotesManager {
  // Singleton pattern
  static final NotesManager instance = NotesManager._internal();
  NotesManager._internal();

  // Store notes by grade
  final Map<String, List<Note>> notes = {};

  void addNote(String grade, Note note) {
    if (!notes.containsKey(grade)) {
      notes[grade] = [];
    }
    notes[grade]!.add(note);
  }

  List<Note> getNotesForGrade(String grade) {
    return notes[grade] ?? [];
  }
}