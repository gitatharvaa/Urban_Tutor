import 'package:flutter/material.dart';

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
  final String grade;
  final String schoolName;
  final String uploaderName;
  final String difficulty;
  final IconData icon;
  final int pages;
  final int downloads;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.downloadedAt,
    required this.type,
    required this.subject,
    required this.size,
    required this.grade,
    required this.schoolName,
    required this.uploaderName,
    required this.difficulty,
    this.icon = Icons.book,
    this.pages = 10,
    this.downloads = 0,
    this.progress = 1.0,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}