// lib/models/note_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String? id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSizeBytes;
  final String uploadedBy;
  final DateTime uploadedAt;
  final DateTime updatedAt;
  final String category;
  final String? description;
  final List<String> tags;
  final String grade;
  final String difficulty;
  final bool isActive;
  final bool isPublic;

  NoteModel({
    this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeBytes,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.updatedAt,
    required this.category,
    this.description,
    required this.tags,
    required this.grade,
    required this.difficulty,
    this.isActive = true,
    this.isPublic = true,
  });

  // Create from Firestore document
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileType: data['fileType'] ?? 'pdf',
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? '',
      description: data['description'],
      tags: List<String>.from(data['tags'] ?? []),
      grade: data['grade'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      isActive: data['isActive'] ?? true,
      isPublic: data['isPublic'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSizeBytes': fileSizeBytes,
      'uploadedBy': uploadedBy,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'category': category,
      'description': description,
      'tags': tags,
      'grade': grade,
      'difficulty': difficulty,
      'isActive': isActive,
      'isPublic': isPublic,
    };
  }

  // Copy with method
  NoteModel copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
    String? uploadedBy,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    String? category,
    String? description,
    List<String>? tags,
    String? grade,
    String? difficulty,
    bool? isActive,
    bool? isPublic,
  }) {
    return NoteModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      grade: grade ?? this.grade,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Helper getters
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isPdf => fileType.toLowerCase() == 'pdf';
  bool get isWord => ['doc', 'docx'].contains(fileType.toLowerCase());
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif'].contains(fileType.toLowerCase());

  @override
  String toString() {
    return 'NoteModel(id: $id, fileName: $fileName, category: $category, grade: $grade)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
