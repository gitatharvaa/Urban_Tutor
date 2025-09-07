// lib/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteCard extends StatelessWidget {
  final dynamic note; // Can be NoteModel or Map
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onDownload;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1024;

    // Get note data safely (works with both NoteModel and Map)
    final title =
        _getProperty('fileName') ?? _getProperty('title') ?? 'Untitled';
    final subject =
        _getProperty('category') ?? _getProperty('subject') ?? 'Unknown';
    final difficulty = _getProperty('difficulty') ?? 'Medium';
    final uploadedBy = _getProperty('uploadedBy') ?? '';

    // Check if current user can delete this note
    final currentUser = FirebaseAuth.instance.currentUser;
    final canDelete = currentUser != null && uploadedBy == currentUser.uid;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative Header (ORIGINAL DESIGN)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Stack(
              children: [
                // File icon (ORIGINAL)
                Center(
                  child: Icon(
                    _getFileIcon(subject), // Use subject to determine icon
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                // 3-dots menu (NEW FUNCTIONALITY)
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          if (onTap != null) onTap!();
                          break;
                        case 'download':
                          if (onDownload != null) onDownload!();
                          break;
                        case 'share':
                          _shareNote(context, title);
                          break;
                        case 'delete':
                          if (onDelete != null) onDelete!();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 18),
                            SizedBox(width: 8),
                            Text('Download'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 18),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      // Only show delete option if user owns the note (NEW FUNCTIONALITY)
                      if (canDelete)
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content (ORIGINAL DESIGN)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with "My Note" indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Owner indicator (NEW FUNCTIONALITY)
                    if (canDelete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'My Note',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subject and Difficulty row (ORIGINAL)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        difficulty,
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

                // Bottom row (ORIGINAL with modified data)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pages, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _getProperty('formattedFileSize') ?? '0 KB',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.download,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          _getProperty('downloads')?.toString() ?? '0',
                          style: const TextStyle(fontSize: 12),
                        ),
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
  }

  // Helper method to get property from both NoteModel and Map
  dynamic _getProperty(String key) {
    try {
      if (note is Map) {
        return note[key];
      } else {
        // For NoteModel objects
        switch (key) {
          case 'fileName':
            return note.fileName;
          case 'title':
            return note.fileName;
          case 'category':
            return note.category;
          case 'subject':
            return note.category;
          case 'difficulty':
            return note.difficulty;
          case 'fileType':
            return note.fileType;
          case 'formattedFileSize':
            return note.formattedFileSize;
          case 'uploadedBy':
            return note.uploadedBy;
          case 'downloads':
            return 0; // Default downloads count
          default:
            return null;
        }
      }
    } catch (e) {
      return null;
    }
  }

  // Original icon mapping based on subject
  IconData _getFileIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Icons.calculate;
      case 'science':
      case 'physics':
      case 'chemistry':
      case 'biology':
        return Icons.science;
      case 'english':
      case 'literature':
        return Icons.menu_book;
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      default:
        return Icons.description;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _shareNote(BuildContext context, String noteTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Sharing $noteTitle...'),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
