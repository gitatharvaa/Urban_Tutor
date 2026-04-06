import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/app_colors.dart';

class ProfileFormSections extends StatefulWidget {
  final File? profileImage;
  final File? qualificationDoc;
  final List<String> selectedSubjects;
  final List<int> selectedStandards;
  final Function(File?) onProfileImagePicked;
  final Function(File?) onQualificationDocPicked;
  final Function(List<String>) onSubjectsChanged;
  final Function(List<int>) onStandardsChanged;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController qualificationController;
  final TextEditingController experienceController;
  final TextEditingController cityController;
  final TextEditingController areaController;
  final TextEditingController monthlyRateController;
  final TextEditingController bioController;
  final TextEditingController whatsappController;
  final TextEditingController facebookController;
  final TextEditingController instagramController;
  final TextEditingController twitterController;
  final ImagePicker picker;

  const ProfileFormSections({
    super.key,
    required this.profileImage,
    required this.qualificationDoc,
    required this.selectedSubjects,
    required this.selectedStandards,
    required this.onProfileImagePicked,
    required this.onQualificationDocPicked,
    required this.onSubjectsChanged,
    required this.onStandardsChanged,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.qualificationController,
    required this.experienceController,
    required this.cityController,
    required this.areaController,
    required this.monthlyRateController,
    required this.bioController,
    required this.whatsappController,
    required this.facebookController,
    required this.instagramController,
    required this.twitterController,
    required this.picker,
  });

  @override
  State<ProfileFormSections> createState() => _ProfileFormSectionsState();
}

class _ProfileFormSectionsState extends State<ProfileFormSections>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  // Enhanced subjects list
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
    'Spanish',
    'Accountancy',
    'Business Studies',
    'Political Science',
    'Psychology',
    'Sociology',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationControllers = List.generate(
      7,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 80)),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOut,
            )))
        .toList();

    _slideAnimations = _animationControllers
        .map((controller) => Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )))
        .toList();

    // Start animations with staggered delays
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) _animationControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Responsive helper methods
  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isTablet => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1024;

  double _getResponsivePadding() {
    if (_isMobile) return 16.0;
    if (_isTablet) return 24.0;
    return 32.0;
  }

  double _getResponsiveSpacing() {
    if (_isMobile) return 20.0;
    if (_isTablet) return 24.0;
    return 28.0;
  }

  double _getResponsiveFontSize(double baseFontSize) {
    if (_isMobile) return baseFontSize;
    if (_isTablet) return baseFontSize + 1;
    return baseFontSize + 2;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding()),
      child: Column(
        children: [
          _buildAnimatedSection(0, _buildProfileImageSection()),
          SizedBox(height: _getResponsiveSpacing()),
          _buildAnimatedSection(1, _buildPersonalInfoSection()),
          SizedBox(height: _getResponsiveSpacing()),
          _buildAnimatedSection(2, _buildProfessionalInfoSection()),
          SizedBox(height: _getResponsiveSpacing()),
          _buildAnimatedSection(3, _buildSubjectsSection()),
          SizedBox(height: _getResponsiveSpacing()),
          _buildAnimatedSection(4, _buildStandardsSection()),
          SizedBox(height: _getResponsiveSpacing()),
          _buildAnimatedSection(5, _buildLocationSection()),
          SizedBox(height: _getResponsiveSpacing()),
          _buildAnimatedSection(6, _buildBioAndSocialSection()),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _slideAnimations[index],
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildProfileImageSection() {
    final imageSize = _isMobile ? 120.0 : _isTablet ? 140.0 : 160.0;
    final padding = _isMobile ? 24.0 : _isTablet ? 28.0 : 32.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primaryBlue.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(_isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: _isMobile ? 15 : 25,
            offset: Offset(0, _isMobile ? 6 : 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (_isMobile)
            // Mobile layout - vertical
            Column(
              children: [
                _buildProfileImageHeader(),
                const SizedBox(height: 20),
                _buildProfileImagePicker(imageSize),
                const SizedBox(height: 16),
                _buildProfileImageButton(),
              ],
            )
          else
            // Tablet/Desktop layout - horizontal
            Row(
              children: [
                Expanded(child: _buildProfileImageHeader()),
                const SizedBox(width: 24),
                Column(
                  children: [
                    _buildProfileImagePicker(imageSize),
                    const SizedBox(height: 16),
                    _buildProfileImageButton(),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImageHeader() {
    return Row(
      mainAxisSize: _isMobile ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: _isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(_isMobile ? 10 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.primaryGreen],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: _isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: _isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: _isMobile ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 4),
              Text(
                'Add a professional photo to build trust with students',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(13),
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                textAlign: _isMobile ? TextAlign.center : TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImagePicker(double imageSize) {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: widget.profileImage != null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.1),
                    AppColors.primaryGreen.withOpacity(0.1),
                  ],
                ),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.2),
              blurRadius: _isMobile ? 15 : 20,
              offset: Offset(0, _isMobile ? 6 : 8),
            ),
          ],
        ),
        child: widget.profileImage != null
            ? ClipOval(
                child: Image.file(
                  widget.profileImage!,
                  fit: BoxFit.cover,
                  width: imageSize,
                  height: imageSize,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: _isMobile ? 32 : 48,
                    color: AppColors.primaryBlue.withOpacity(0.7),
                  ),
                  SizedBox(height: _isMobile ? 4 : 8),
                  Text(
                    'Tap to add',
                    style: TextStyle(
                      fontSize: _isMobile ? 12 : 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileImageButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _pickProfileImage,
        icon: Icon(
          widget.profileImage != null
              ? Icons.edit_rounded
              : Icons.add_a_photo_rounded,
          size: _isMobile ? 18 : 20,
        ),
        label: Text(
          widget.profileImage != null ? 'Change Picture' : 'Add Picture',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: _isMobile ? 16 : 24, 
            vertical: _isMobile ? 12 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      subtitle: 'Tell us about yourself',
      icon: Icons.person_rounded,
      iconGradient: [AppColors.primaryBlue, AppColors.primaryGreen],
      children: [
        _buildTextField(
          controller: widget.nameController,
          label: 'Full Name',
          icon: Icons.person_outline_rounded,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter your name' : null,
        ),
        SizedBox(height: _isMobile ? 16 : 20),
        _buildTextField(
          controller: widget.emailController,
          label: 'Email (Optional)',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: _isMobile ? 16 : 20),
        _buildTextField(
          controller: widget.phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter your phone number';
            if (!RegExp(r'^[\+]?[0-9]{10,15}$').hasMatch(value!)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return _buildSection(
      title: 'Professional Information',
      subtitle: 'Your qualifications and experience',
      icon: Icons.work_rounded,
      iconGradient: [Colors.orange, Colors.deepOrange],
      children: [
        if (_isMobile)
          // Mobile - vertical layout
          Column(
            children: [
              _buildTextField(
                controller: widget.qualificationController,
                label: 'Qualification',
                icon: Icons.school_outlined,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter your qualification'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: widget.experienceController,
                label: 'Experience (years)',
                icon: Icons.work_history_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter your experience'
                    : null,
              ),
            ],
          )
        else
          // Tablet/Desktop - horizontal layout
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: widget.qualificationController,
                  label: 'Qualification',
                  icon: Icons.school_outlined,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter your qualification'
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: widget.experienceController,
                  label: 'Experience (years)',
                  icon: Icons.work_history_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter your experience'
                      : null,
                ),
              ),
            ],
          ),
        SizedBox(height: _isMobile ? 16 : 20),
        _buildTextField(
          controller: widget.monthlyRateController,
          label: 'Monthly Rate (₹)',
          icon: Icons.currency_rupee_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty ?? true
              ? 'Please enter your monthly rate'
              : null,
        ),
        SizedBox(height: _isMobile ? 20 : 24),
        _buildQualificationDocSection(),
      ],
    );
  }

  Widget _buildQualificationDocSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed overflow by making text responsive and flexible
        Row(
          children: [
            Icon(
              Icons.verified_rounded,
              color: AppColors.primaryGreen,
              size: _isMobile ? 18 : 20,
            ),
            SizedBox(width: _isMobile ? 6 : 8),
            Flexible(
              child: Text(
                'Qualification Document (Optional)',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a document to verify your qualifications and build trust',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(12),
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickQualificationDoc,
          child: Container(
            width: double.infinity,
            height: _isMobile ? 120 : 140,
            decoration: BoxDecoration(
              gradient: widget.qualificationDoc != null
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.04),
                        AppColors.primaryGreen.withOpacity(0.04),
                      ],
                    ),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: widget.qualificationDoc != null
                ? Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.qualificationDoc!,
                            fit: BoxFit.cover,
                            height: _isMobile ? 100 : 120,
                            width: _isMobile ? 100 : 120,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => widget.onQualificationDocPicked(null),
                          child: Container(
                            padding: EdgeInsets.all(_isMobile ? 6 : 8),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: _isMobile ? 16 : 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(_isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.upload_file_rounded,
                          size: _isMobile ? 24 : 32,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: _isMobile ? 8 : 12),
                      Text(
                        'Tap to upload document',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: _getResponsiveFontSize(14),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supported formats: JPG, PNG',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: _getResponsiveFontSize(10),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsSection() {
    return _buildSection(
      title: 'Subjects You Teach',
      subtitle: 'Select your areas of expertise',
      icon: Icons.menu_book_rounded,
      iconGradient: [Colors.purple, Colors.deepPurple],
      children: [
        Wrap(
          spacing: _isMobile ? 8.0 : 12.0,
          runSpacing: _isMobile ? 8.0 : 12.0,
          children: _commonSubjects.map((subject) {
            final isSelected = widget.selectedSubjects.contains(subject);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: FilterChip(
                label: Text(
                  subject,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _getResponsiveFontSize(12),
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  List<String> newSubjects = List.from(widget.selectedSubjects);
                  if (selected) {
                    newSubjects.add(subject);
                  } else {
                    newSubjects.remove(subject);
                  }
                  widget.onSubjectsChanged(newSubjects);
                },
                selectedColor: AppColors.primaryBlue,
                backgroundColor: AppColors.background,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.primaryBlue.withOpacity(0.3),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: isSelected ? 6 : 2,
                shadowColor: isSelected
                    ? AppColors.primaryBlue.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                padding: EdgeInsets.symmetric(
                  horizontal: _isMobile ? 12 : 16, 
                  vertical: _isMobile ? 6 : 8,
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.selectedSubjects.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(_isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: _isMobile ? 18 : 20,
                ),
                SizedBox(width: _isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Please select at least one subject to continue',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: _getResponsiveFontSize(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStandardsSection() {
    return _buildSection(
      title: 'Standards You Teach',
      subtitle: 'Choose the grade levels you are comfortable with',
      icon: Icons.grade_rounded,
      iconGradient: [Colors.teal, Colors.cyan],
      children: [
        Wrap(
          spacing: _isMobile ? 8.0 : 12.0,
          runSpacing: _isMobile ? 8.0 : 12.0,
          children: List.generate(12, (index) {
            final standard = index + 1;
            final isSelected = widget.selectedStandards.contains(standard);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FilterChip(
                label: Text(
                  '$standard${_getOrdinalSuffix(standard)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _getResponsiveFontSize(14),
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  List<int> newStandards = List.from(widget.selectedStandards);
                  if (selected) {
                    newStandards.add(standard);
                  } else {
                    newStandards.remove(standard);
                  }
                  widget.onStandardsChanged(newStandards);
                },
                selectedColor: AppColors.primaryGreen,
                backgroundColor: AppColors.background,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withOpacity(0.3),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: isSelected ? 6 : 2,
                shadowColor: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                padding: EdgeInsets.symmetric(
                  horizontal: _isMobile ? 16 : 20, 
                  vertical: _isMobile ? 8 : 10,
                ),
              ),
            );
          }),
        ),
        if (widget.selectedStandards.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(_isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: _isMobile ? 18 : 20,
                ),
                SizedBox(width: _isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Please select at least one standard to continue',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: _getResponsiveFontSize(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Location',
      subtitle: 'Where do you provide tutoring services?',
      icon: Icons.location_on_rounded,
      iconGradient: [Colors.red, Colors.pink],
      children: [
        if (_isMobile)
          // Mobile - vertical layout
          Column(
            children: [
              _buildTextField(
                controller: widget.cityController,
                label: 'City',
                icon: Icons.location_city_outlined,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your city' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: widget.areaController,
                label: 'Area',
                icon: Icons.location_on_outlined,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your area' : null,
              ),
            ],
          )
        else
          // Tablet/Desktop - horizontal layout
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: widget.cityController,
                  label: 'City',
                  icon: Icons.location_city_outlined,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your city' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: widget.areaController,
                  label: 'Area',
                  icon: Icons.location_on_outlined,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your area' : null,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBioAndSocialSection() {
    return Column(
      children: [
        _buildSection(
          title: 'About You',
          subtitle: 'Describe your teaching philosophy and approach',
          icon: Icons.description_rounded,
          iconGradient: [Colors.indigo, Colors.blue],
          children: [
            _buildTextField(
              controller: widget.bioController,
              label: 'Tell students about your teaching style and experience',
              icon: Icons.edit_note_rounded,
              maxLines: _isMobile ? 3 : 4,
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please add a brief description'
                  : null,
            ),
          ],
        ),
        SizedBox(height: _getResponsiveSpacing()),
        _buildSection(
          title: 'Social Media (Optional)',
          subtitle: 'Connect with students on social platforms',
          icon: Icons.share_rounded,
          iconGradient: [Colors.green, Colors.teal],
          children: [
            // All social media fields in vertical layout
            _buildTextField(
              controller: widget.whatsappController,
              label: 'WhatsApp Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: _isMobile ? 16 : 20),
            _buildTextField(
              controller: widget.facebookController,
              label: 'Facebook Profile',
              icon: Icons.facebook_outlined,
            ),
            SizedBox(height: _isMobile ? 16 : 20),
            _buildTextField(
              controller: widget.instagramController,
              label: 'Instagram Handle',
              icon: Icons.camera_alt_outlined,
            ),
            SizedBox(height: _isMobile ? 16 : 20),
            _buildTextField(
              controller: widget.twitterController,
              label: 'Twitter Handle',
              icon: Icons.alternate_email_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconGradient,
    required List<Widget> children,
  }) {
    final padding = _isMobile ? 20.0 : _isTablet ? 24.0 : 28.0;
    final iconPadding = _isMobile ? 12.0 : 16.0;
    final iconSize = _isMobile ? 24.0 : 28.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: _isMobile ? 15 : 25,
            offset: Offset(0, _isMobile ? 6 : 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient[0].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(width: _isMobile ? 16 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(12),
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _isMobile ? 20 : 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.05),
            blurRadius: _isMobile ? 5 : 10,
            offset: Offset(0, _isMobile ? 2 : 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(14),
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: _getResponsiveFontSize(13),
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(_isMobile ? 8 : 10),
            padding: EdgeInsets.all(_isMobile ? 8 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: _isMobile ? 18 : 22,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(0.2),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(0.2),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primaryBlue,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 2.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: _isMobile ? 16 : 20,
            vertical: _isMobile ? 16 : 20,
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await widget.picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      widget.onProfileImagePicked(File(image.path));
    }
  }

  Future<void> _pickQualificationDoc() async {
    final XFile? image = await widget.picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );
    if (image != null) {
      widget.onQualificationDocPicked(File(image.path));
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
}
