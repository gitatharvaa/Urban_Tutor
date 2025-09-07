// lib/screens/add_notes_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/notes_provider.dart';
import '../services/notes_service.dart';

class AddNotesPage extends StatefulWidget {
  final String? initialGrade;
  final String? initialSubject;

  const AddNotesPage({
    super.key,
    this.initialGrade,
    this.initialSubject,
  });

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedGrade = '1'; // Changed from '10' to '1'
  String _selectedSubject = 'Mathematics';
  String _selectedDifficulty = 'Medium';
  File? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _isPublic = true;

  // Updated grades from 1-10
  final List<String> _grades = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> _subjects = [
    'Mathematics', 'Science', 'English', 'History', 
    'Geography', 'Physics', 'Chemistry', 'Biology'
  ];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    // Set initial values if provided
    if (widget.initialGrade != null && _grades.contains(widget.initialGrade)) {
      _selectedGrade = widget.initialGrade!;
    }
    if (widget.initialSubject != null && _subjects.contains(widget.initialSubject)) {
      _selectedSubject = widget.initialSubject!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Responsive breakpoints
    final isPhone = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive padding and spacing
    final horizontalPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 16.0;
    final verticalSpacing = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final borderRadius = isDesktop ? 16.0 : 12.0;
    
    // Form width constraint for larger screens
    final formWidth = isDesktop ? 600.0 : isTablet ? 500.0 : double.infinity;
    
    // Responsive font sizes
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final bodyFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Note',
          style: TextStyle(fontSize: titleFontSize),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: isDesktop ? 2 : 1,
        actions: [
          if (_selectedFile != null)
            IconButton(
              onPressed: () {
                setState(() => _selectedFile = null);
              },
              icon: const Icon(Icons.clear),
              tooltip: 'Remove file',
              iconSize: isDesktop ? 28 : 24,
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isDesktop ? 32 : 16,
          ),
          child: Container(
            width: formWidth,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  if (_isUploading) ...[
                    Card(
                      elevation: isDesktop ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(verticalSpacing),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                              minHeight: isDesktop ? 6 : 4,
                            ),
                            SizedBox(height: verticalSpacing * 0.5),
                            Text(
                              'Uploading... ${(_uploadProgress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: bodyFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                  ],

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(fontSize: bodyFontSize),
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      labelStyle: TextStyle(fontSize: bodyFontSize),
                      hintText: 'Enter note title',
                      hintStyle: TextStyle(fontSize: bodyFontSize * 0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      prefixIcon: Icon(
                        Icons.title,
                        size: isDesktop ? 24 : 20,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 20 : 16,
                        vertical: isDesktop ? 18 : 14,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(fontSize: bodyFontSize),
                    decoration: InputDecoration(
                      labelText: 'Description *',
                      labelStyle: TextStyle(fontSize: bodyFontSize),
                      hintText: 'Describe what this note covers',
                      hintStyle: TextStyle(fontSize: bodyFontSize * 0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      prefixIcon: Icon(
                        Icons.description,
                        size: isDesktop ? 24 : 20,
                      ),
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 20 : 16,
                        vertical: isDesktop ? 18 : 14,
                      ),
                    ),
                    maxLines: isDesktop ? 5 : 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // Row for Grade and Subject
                  isPhone
                    ? Column(
                        children: [
                          _buildGradeDropdown(bodyFontSize, borderRadius, isDesktop),
                          SizedBox(height: verticalSpacing),
                          _buildSubjectDropdown(bodyFontSize, borderRadius, isDesktop),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _buildGradeDropdown(bodyFontSize, borderRadius, isDesktop)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSubjectDropdown(bodyFontSize, borderRadius, isDesktop)),
                        ],
                      ),
                  SizedBox(height: verticalSpacing),

                  // Difficulty and Public settings
                  isPhone
                    ? Column(
                        children: [
                          _buildDifficultyDropdown(bodyFontSize, borderRadius, isDesktop),
                          SizedBox(height: verticalSpacing),
                          _buildPublicToggle(bodyFontSize, borderRadius, isDesktop),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _buildDifficultyDropdown(bodyFontSize, borderRadius, isDesktop)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPublicToggle(bodyFontSize, borderRadius, isDesktop)),
                        ],
                      ),
                  SizedBox(height: verticalSpacing),

                  // File Selection
                  _buildFileSelection(screenSize, bodyFontSize, borderRadius, isDesktop),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isUploading ? null : _submitNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 18 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      elevation: isDesktop ? 3 : 2,
                    ),
                    child: _isUploading
                        ? SizedBox(
                            height: isDesktop ? 24 : 20,
                            width: isDesktop ? 24 : 20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save,
                                size: isDesktop ? 24 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedFile != null ? 'Upload Note' : 'Add Note',
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeDropdown(double fontSize, double borderRadius, bool isDesktop) {
    return DropdownButtonFormField<String>(
      value: _selectedGrade,
      style: TextStyle(
        fontSize: fontSize,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: 'Grade *',
        labelStyle: TextStyle(fontSize: fontSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        prefixIcon: Icon(
          Icons.school,
          size: isDesktop ? 24 : 20,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 18 : 14,
        ),
      ),
      items: _grades.map((grade) {
        return DropdownMenuItem(
          value: grade,
          child: Text(
            'Grade $grade',
            style: TextStyle(fontSize: fontSize),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedGrade = value!);
      },
    );
  }

  Widget _buildSubjectDropdown(double fontSize, double borderRadius, bool isDesktop) {
    return DropdownButtonFormField<String>(
      value: _selectedSubject,
      style: TextStyle(
        fontSize: fontSize,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: 'Subject *',
        labelStyle: TextStyle(fontSize: fontSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        prefixIcon: Icon(
          Icons.subject,
          size: isDesktop ? 24 : 20,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 18 : 14,
        ),
      ),
      items: _subjects.map((subject) {
        return DropdownMenuItem(
          value: subject,
          child: Text(
            subject,
            style: TextStyle(fontSize: fontSize),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedSubject = value!);
      },
    );
  }

  Widget _buildDifficultyDropdown(double fontSize, double borderRadius, bool isDesktop) {
    return DropdownButtonFormField<String>(
      value: _selectedDifficulty,
      style: TextStyle(
        fontSize: fontSize,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: 'Difficulty *',
        labelStyle: TextStyle(fontSize: fontSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        prefixIcon: Icon(
          Icons.trending_up,
          size: isDesktop ? 24 : 20,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 18 : 14,
        ),
      ),
      items: _difficulties.map((difficulty) {
        return DropdownMenuItem(
          value: difficulty,
          child: Row(
            children: [
              Icon(
                _getDifficultyIcon(difficulty),
                size: 16,
                color: _getDifficultyColor(difficulty),
              ),
              const SizedBox(width: 8),
              Text(
                difficulty,
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedDifficulty = value!);
      },
    );
  }

  Widget _buildPublicToggle(double fontSize, double borderRadius, bool isDesktop) {
    return Card(
      elevation: isDesktop ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Row(
          children: [
            Icon(
              _isPublic ? Icons.public : Icons.lock,
              color: Theme.of(context).colorScheme.primary,
              size: isDesktop ? 24 : 20,
            ),
            SizedBox(width: isDesktop ? 12 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isPublic ? 'Public' : 'Private',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                  Text(
                    _isPublic ? 'Everyone can see' : 'Only you can see',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: fontSize * 0.9,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelection(Size screenSize, double fontSize, double borderRadius, bool isDesktop) {
    return Card(
      elevation: isDesktop ? 3 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: _isUploading ? null : _pickFile,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 20),
          child: Column(
            children: [
              if (_selectedFile == null) ...[
                Icon(
                  Icons.cloud_upload_outlined,
                  size: isDesktop ? 64 : 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                Text(
                  'Upload File (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize * 1.1,
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Text(
                  'PDF, DOC, DOCX, TXT, JPG, PNG (Max 50MB)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: fontSize * 0.9,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickFile,
                  icon: Icon(
                    Icons.attach_file,
                    size: isDesktop ? 20 : 18,
                  ),
                  label: Text(
                    'Choose File',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 20,
                      vertical: isDesktop ? 12 : 10,
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 16 : 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      ),
                      child: Icon(
                        _getFileIcon(_selectedFile!.path.split('/').last),
                        color: Theme.of(context).colorScheme.primary,
                        size: isDesktop ? 32 : 24,
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile!.path.split('/').last,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          FutureBuilder<int>(
                            future: _selectedFile!.length(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final size = snapshot.data!;
                                final sizeStr = size < 1024 * 1024
                                    ? '${(size / 1024).toStringAsFixed(1)} KB'
                                    : '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
                                return Text(
                                  sizeStr,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: fontSize * 0.9,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isUploading ? null : () {
                        setState(() => _selectedFile = null);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.error,
                        size: isDesktop ? 24 : 20,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final file = await NotesService.pickFile();
      if (file != null) {
        setState(() => _selectedFile = file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final notesProvider = context.read<NotesProvider>();

      if (_selectedFile != null) {
        // Simulate progress updates
        for (int i = 0; i <= 90; i += 15) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            setState(() => _uploadProgress = i / 100);
          }
        }

        await notesProvider.uploadNote(
          file: _selectedFile!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedSubject,
          grade: _selectedGrade,
          difficulty: _selectedDifficulty,
          isPublic: _isPublic,
        );
      } else {
        await notesProvider.addNote(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          grade: _selectedGrade,
          subject: _selectedSubject,
          difficulty: _selectedDifficulty,
        );
      }

      // Complete progress
      setState(() => _uploadProgress = 1.0);
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Note added successfully for Grade $_selectedGrade!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Return with success and grade info
        Navigator.pop(context, {
          'success': true,
          'grade': _selectedGrade,
          'subject': _selectedSubject,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  IconData _getFileIcon(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
