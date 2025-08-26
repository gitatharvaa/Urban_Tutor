import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'dart:io';
import '../providers/tutor_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class AddTutorProfilePage extends StatefulWidget {
  const AddTutorProfilePage({super.key});

  @override
  State<AddTutorProfilePage> createState() => _AddTutorProfilePageState();
}

class _AddTutorProfilePageState extends State<AddTutorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _monthlyRateController = TextEditingController();
  final _bioController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();

  File? _profileImage;
  File? _qualificationDoc;
  List<String> _selectedSubjects = [];
  List<int> _selectedStandards = [];
  final ImagePicker _picker = ImagePicker();

  // Common subjects for chips
  final List<String> _commonSubjects = [
    'Mathematics',
    'Science',
    'English',
    'Hindi',
    'Social Studies',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Economics',
    'History',
    'Geography',
    'Sanskrit',
    'French',
    'Spanish'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _monthlyRateController.dispose();
    _bioController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: AppColors.educationalColorScheme,
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: const Text(
            'Add Tutor Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileImageSection(),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildProfessionalInfoSection(),
                const SizedBox(height: 24),
                _buildSubjectsSection(),
                const SizedBox(height: 24),
                _buildStandardsSection(),
                const SizedBox(height: 24),
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildBioSection(),
                const SizedBox(height: 24),
                _buildSocialMediaSection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: AppColors.primaryBlue,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _pickProfileImage,
              child: Text(
                _profileImage != null
                    ? 'Change Profile Picture'
                    : 'Add Profile Picture',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration('Full Name', Icons.person),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration:
                  _buildInputDecoration('Email (Optional)', Icons.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: _buildInputDecoration('Phone Number', Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Please enter your phone number';
                if (!RegExp(r'^[\+]?[0-9]{10,15}$').hasMatch(value!)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qualificationController,
              decoration: _buildInputDecoration('Qualification', Icons.school),
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please enter your qualification'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _experienceController,
              decoration:
                  _buildInputDecoration('Experience (in years)', Icons.work),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please enter your experience'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _monthlyRateController,
              decoration: _buildInputDecoration(
                  'Monthly Rate (₹)', Icons.currency_rupee),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please enter your monthly rate'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildQualificationDocSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationDocSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qualification Document (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickQualificationDoc,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.background,
            ),
            child: _qualificationDoc != null
                ? Stack(
                    children: [
                      Center(
                        child: Image.file(
                          _qualificationDoc!,
                          fit: BoxFit.contain,
                          height: 80,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _qualificationDoc = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 40,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload qualification document',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subjects You Teach',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _commonSubjects.map((subject) {
                final isSelected = _selectedSubjects.contains(subject);
                return FilterChip(
                  label: Text(subject),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSubjects.add(subject);
                      } else {
                        _selectedSubjects.remove(subject);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryBlue.withOpacity(0.3),
                  checkmarkColor: AppColors.primaryBlue,
                );
              }).toList(),
            ),
            if (_selectedSubjects.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one subject',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardsSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Standards You Teach',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(10, (index) {
                final standard = index + 1;
                final isSelected = _selectedStandards.contains(standard);
                return FilterChip(
                  label: Text('$standard${_getOrdinalSuffix(standard)}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedStandards.add(standard);
                      } else {
                        _selectedStandards.remove(standard);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryGreen.withOpacity(0.3),
                  checkmarkColor: AppColors.primaryGreen,
                );
              }),
            ),
            if (_selectedStandards.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one standard',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: _buildInputDecoration('City', Icons.location_city),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter your city' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaController,
              decoration: _buildInputDecoration('Area', Icons.location_on),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter your area' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: _buildInputDecoration(
                  'Describe your teaching style and experience',
                  Icons.description),
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please add a brief description'
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Media (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _whatsappController,
              decoration: _buildInputDecoration('WhatsApp Number', Icons.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _facebookController,
              decoration:
                  _buildInputDecoration('Facebook Profile', Icons.facebook),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramController,
              decoration:
                  _buildInputDecoration('Instagram Handle', Icons.camera_alt),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _twitterController,
              decoration: _buildInputDecoration(
                  'Twitter Handle', Icons.alternate_email),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Consumer<TutorProvider>(
      builder: (context, tutorProvider, child) {
        return Column(
          children: [
            if (tutorProvider.uploadProgress > 0 &&
                tutorProvider.uploadProgress < 1)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: tutorProvider.uploadProgress,
                    backgroundColor: AppColors.background,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploading... ${(tutorProvider.uploadProgress * 100).toInt()}%',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              onPressed: tutorProvider.isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: tutorProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Profile',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _pickQualificationDoc() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _qualificationDoc = File(image.path);
      });
    }
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one subject'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedStandards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one standard'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tutorProvider = Provider.of<TutorProvider>(context, listen: false);

    final user = authProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User not authenticated'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final tutor = TutorModel(
      personalInfo: PersonalInfo(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageUrl: '', // Will be set by provider after upload
      ),
      professionalInfo: ProfessionalInfo(
        qualification: _qualificationController.text.trim(),
        qualificationImageUrl: '', // Will be set by provider after upload
        experience: int.parse(_experienceController.text),
        subjects: _selectedSubjects,
        specializations: [],
        monthlyRate: double.parse(_monthlyRateController.text),
      ),
      availability: AvailabilityInfo(
        standards: _selectedStandards,
        timeSlots: {},
      ),
      location: LocationInfo(
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        address: '',
      ),
      socialMedia: SocialMediaInfo(
        whatsapp: _whatsappController.text.trim(),
        facebook: _facebookController.text.trim(),
        instagram: _instagramController.text.trim(),
        twitter: _twitterController.text.trim(),
      ),
      ratings: RatingInfo(
        averageRating: 0.0,
        totalReviews: 0,
      ),
      metadata: MetadataInfo(
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      bio: _bioController.text.trim(),
    );

    bool success = await tutorProvider.addTutorProfile(
      tutor: tutor,
      profileImage: _profileImage,
      qualificationDoc: _qualificationDoc,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted && tutorProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tutorProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
