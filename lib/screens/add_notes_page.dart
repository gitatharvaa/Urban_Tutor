import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:urban_tutor/notes_provider.dart';

class AddNotesPage extends StatefulWidget {
  final String grade;

  const AddNotesPage({super.key, required this.grade});

  @override
  _AddNotesPageState createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedSubject = 'Mathematics';
  String _selectedDifficulty = 'Easy';
  String? _uploadedFileName;
  PlatformFile? _selectedFile;

  final List<String> _subjectOptions = [
    'Mathematics',
    'Science',
    'Marathi',
    'English',
    'Hindi',
    'French',
    'Sanskrit',
    'Geography',
    'Social Studies'
  ];
  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Advanced'];

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _uploadedFileName = result.files.single.name;
        _selectedFile = result.files.first;
      });
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await context.read<NotesProvider>().addNote(
            title: _bookTitleController.text,
            description: _descriptionController.text,
            subject: _selectedSubject,
            difficulty: _selectedDifficulty,
            grade: widget.grade,
            schoolName: _schoolController.text,
            uploaderName: _nameController.text,
            fileSize: _selectedFile!.size,
            platformFile: _selectedFile!,
          );

      if (!mounted) return;

      // Refresh the notes list
      await context.read<NotesProvider>().fetchNotes(
            grade: widget.grade,
            subject: _selectedSubject == 'All' ? null : _selectedSubject,
            difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<NotesProvider>().fetchNotes(
    //     grade: widget.grade,
    //     subject: _selectedSubject == 'All' ? null : _selectedSubject,
    //     difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
    //   );
    // });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _bookTitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Notes'),
        backgroundColor: Colors.orange[200],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Your Name',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _schoolController,
                      label: 'School Name',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter school name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bookTitleController,
                      label: 'Book Title',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter book title' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter description' : null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Subject',
                      value: _selectedSubject,
                      items: _subjectOptions,
                      onChanged: (value) =>
                          setState(() => _selectedSubject = value!),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Difficulty',
                      value: _selectedDifficulty,
                      items: _difficultyOptions,
                      onChanged: (value) =>
                          setState(() => _selectedDifficulty = value!),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: Text(_uploadedFileName ?? 'Upload PDF/Doc'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[100],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit Notes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.orange.shade50,
      ),
      validator: validator,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[100]!),
        ),
        filled: true,
        fillColor: Colors.orange.shade50,
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
