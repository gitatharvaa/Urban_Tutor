enum NoteType { pdf, video, document, presentation, audio }

class Note {
  final String id;
  final String title;
  final String description;
  final DateTime downloadedAt;
  final NoteType type;
  final String subject;
  final int size;
  final double progress;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.downloadedAt,
    required this.type,
    required this.subject,
    required this.size,
    this.progress = 1.0,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}