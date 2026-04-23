import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'dart:io';
import '../providers/tutor_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AddTutorProfilePage — Premium 3-Step Wizard Redesign
// ─────────────────────────────────────────────────────────────────────────────

class AddTutorProfilePage extends StatefulWidget {
  const AddTutorProfilePage({super.key});

  @override
  State<AddTutorProfilePage> createState() => _AddTutorProfilePageState();
}

class _AddTutorProfilePageState extends State<AddTutorProfilePage> {
  // ── Page / Step state ──────────────────────────────────────────────────────
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // ── Form keys — one per step ───────────────────────────────────────────────
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // ── Text controllers ───────────────────────────────────────────────────────
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

  // ── State variables ────────────────────────────────────────────────────────
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedGender = '';

  // Step 2 state
  final List<String> _selectedSubjects = [];
  final List<int> _selectedStandards = [];
  final List<String> _selectedTeachingModes = [];
  final List<String> _selectedLanguages = [];

  // Step 3 state
  final List<int> _selectedDays = []; // 0=Mon ... 6=Sun
  final List<String> _selectedTimeSlots = [];

  // Location validation state
  double? _validatedLat;
  double? _validatedLng;
  bool _isValidatingLocation = false;
  bool _locationValidated = false;
  String? _locationError;
  bool _isUsingCurrentLocation = false;

  // ── Data lists ─────────────────────────────────────────────────────────────
  static const _subjects = [
    'Mathematics', 'Science', 'English', 'Hindi', 'SST / History',
    'Geography', 'Computer', 'Physics', 'Chemistry', 'Biology',
    'Sanskrit', 'Marathi',
  ];
  static const _grades = ['1st','2nd','3rd','4th','5th','6th','7th','8th','9th','10th'];
  static const _teachingModes = ['Home Visit', 'At My Place', 'Online'];
  static const _teachingModeIcons = [Icons.home_work_outlined, Icons.school_outlined, Icons.video_call_outlined];
  static const _languages = ['Hindi', 'English', 'Marathi', 'Both Hindi & English'];
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _timeSlots = [
    'Morning (6–9 AM)', 'Forenoon (9–12 PM)', 'Afternoon (12–4 PM)',
    'Evening (4–7 PM)', 'Night (7–9 PM)',
  ];
  static const _stepLabels = ['Personal Info', 'Teaching Details', 'Location & Fees'];
  static const _stepSubtitles = [
    "Let's start with your basic information",
    "Tell parents what you specialise in",
    "Help parents find you easily",
  ];
  static const _quickFees = ['500', '1000', '2000', '3000'];

  @override
  void initState() {
    super.initState();
    // Reset location validation when city/area text changes
    _cityController.addListener(_onLocationTextChanged);
    _areaController.addListener(_onLocationTextChanged);
  }

  void _onLocationTextChanged() {
    if (_locationValidated) {
      setState(() {
        _locationValidated = false;
        _validatedLat = null;
        _validatedLng = null;
        _locationError = null;
      });
    }
  }

  @override
  void dispose() {
    _cityController.removeListener(_onLocationTextChanged);
    _areaController.removeListener(_onLocationTextChanged);
    _pageController.dispose();
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

  // ─── Navigation helpers ────────────────────────────────────────────────────
  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentStep = step);
  }

  void _nextStep() {
    // Validate current step
    if (_currentStep == 0 && !(_formKey1.currentState?.validate() ?? false)) return;
    if (_currentStep == 1) {
      if (_selectedSubjects.isEmpty) {
        _showErrorSnackBar('Please select at least one subject');
        return;
      }
      if (_selectedStandards.isEmpty) {
        _showErrorSnackBar('Please select at least one standard');
        return;
      }
    }
    if (_currentStep == 2) {
      if (!(_formKey3.currentState?.validate() ?? false)) return;
      // Enforce location validation before save
      if (!_locationValidated || _validatedLat == null || _validatedLng == null) {
        // Try auto-validating
        final city = _cityController.text.trim();
        final area = _areaController.text.trim();
        if (city.isEmpty || area.isEmpty) {
          _showErrorSnackBar('Please enter your City and Area');
          return;
        }
        _showErrorSnackBar('Please verify your location before creating profile');
        _validateLocation();
        return;
      }
      _saveProfile();
      return;
    }
    _goToStep(_currentStep + 1);
  }

  void _prevStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Tutor Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          // ── Step progress header
          _buildStepProgressHeader(isTablet),

          // ── PageView body
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStep1(isTablet),
                _buildStep2(isTablet),
                _buildStep3(isTablet),
              ],
            ),
          ),

          // ── Bottom action bar
          _buildBottomBar(isTablet),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  STEP PROGRESS HEADER
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildStepProgressHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
      ),
      child: Column(
        children: [
          // Step circles + connecting lines
          Row(
            children: List.generate(5, (i) {
              if (i.isEven) {
                // Step circle
                final stepIndex = i ~/ 2;
                return _buildStepCircle(stepIndex);
              } else {
                // Connecting line
                final lineIndex = i ~/ 2;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentStep > lineIndex
                          ? AppColors.primaryBlue
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 10),
          // Subtitle
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _stepSubtitles[_currentStep],
              key: ValueKey(_currentStep),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepIndex) {
    final isCompleted = _currentStep > stepIndex;
    final isActive = _currentStep == stepIndex;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primaryBlue
                : isActive ? Colors.white : const Color(0xFFF5F7FA),
            border: Border.all(
              color: isCompleted || isActive
                  ? AppColors.primaryBlue
                  : const Color(0xFFDDDDDD),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.primaryBlue : const Color(0xFFAAAAAA),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _stepLabels[stepIndex],
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive || isCompleted ? AppColors.primaryBlue : const Color(0xFFAAAAAA),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  STEP 1 — Personal Info
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildStep1(bool isTablet) {
    final hPad = isTablet ? MediaQuery.of(context).size.width * 0.12 : 20.0;
    final photoRadius = isTablet ? 70.0 : 55.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile photo picker ──
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(photoRadius + 5),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _profileImage != null
                            ? ClipOval(
                                key: ValueKey(_profileImage!.path),
                                child: Image.file(
                                  _profileImage!,
                                  width: photoRadius * 2,
                                  height: photoRadius * 2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                key: const ValueKey('placeholder'),
                                width: photoRadius * 2,
                                height: photoRadius * 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(Icons.person_rounded, size: 52, color: AppColors.primaryBlue),
                                    ),
                                    Positioned(
                                      bottom: 0, right: 0,
                                      child: Container(
                                        width: 30, height: 30,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tap to add photo', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF757575))),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Form fields ──
            if (isTablet)
              Row(children: [
                Expanded(child: _buildInputField('Full Name', 'e.g. Priya Sharma', Icons.person_outline_rounded, _nameController, TextInputType.name, required: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField('Phone Number', '10-digit mobile number', Icons.phone_outlined, _phoneController, TextInputType.phone, required: true)),
              ])
            else ...[
              _buildInputField('Full Name', 'e.g. Priya Sharma', Icons.person_outline_rounded, _nameController, TextInputType.name, required: true),
              const SizedBox(height: 20),
              _buildInputField('Phone Number', '10-digit mobile number', Icons.phone_outlined, _phoneController, TextInputType.phone, required: true),
            ],
            const SizedBox(height: 20),
            if (isTablet)
              Row(children: [
                Expanded(child: _buildInputField('Email Address', 'yourname@gmail.com', Icons.email_outlined, _emailController, TextInputType.emailAddress)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField('Years of Experience', 'e.g. 5', Icons.workspace_premium_outlined, _experienceController, TextInputType.number, required: true)),
              ])
            else ...[
              _buildInputField('Email Address', 'yourname@gmail.com', Icons.email_outlined, _emailController, TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildInputField('Years of Experience', 'e.g. 5', Icons.workspace_premium_outlined, _experienceController, TextInputType.number, required: true),
            ],
            const SizedBox(height: 20),

            // ── Qualification ──
            _buildInputField('Qualification', 'e.g. B.Ed, M.Sc', Icons.school_outlined, _qualificationController, TextInputType.text, required: true),
            const SizedBox(height: 24),

            // ── Gender selection ──
            _buildLabel('Gender'),
            const SizedBox(height: 6),
            Row(
              children: ['Male', 'Female', 'Prefer not to say'].map((g) {
                final sel = _selectedGender == g;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: g != 'Prefer not to say' ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: sel ? null : Border.all(color: const Color(0xFFDDDDDD)),
                        ),
                        child: Text(
                          g,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            color: sel ? Colors.white : const Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  STEP 2 — Teaching Details
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildStep2(bool isTablet) {
    final hPad = isTablet ? MediaQuery.of(context).size.width * 0.12 : 20.0;
    final gradeWidth = (MediaQuery.of(context).size.width - (hPad * 2) - 40) / 5;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Subjects ──
            _buildLabel('Subjects You Teach', required: true),
            Text('Select all that apply', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF757575))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: _subjects.map((s) {
                final sel = _selectedSubjects.contains(s);
                return GestureDetector(
                  onTap: () => setState(() => sel ? _selectedSubjects.remove(s) : _selectedSubjects.add(s)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: sel ? null : Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sel) ...[
                          const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(s, style: GoogleFonts.poppins(fontSize: isTablet ? 13 : 12, fontWeight: FontWeight.w500, color: sel ? Colors.white : const Color(0xFF2D2D2D))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Standards ──
            _buildLabel('Standards You Teach', required: true),
            Text('(Class 1 – 10)', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF757575))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(10, (i) {
                final stdNum = i + 1;
                final sel = _selectedStandards.contains(stdNum);
                return GestureDetector(
                  onTap: () => setState(() => sel ? _selectedStandards.remove(stdNum) : _selectedStandards.add(stdNum)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: gradeWidth.clamp(44, 70),
                    height: isTablet ? 52 : 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? null : Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Text(
                      _grades[i],
                      style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? Colors.white : const Color(0xFF757575),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ── Teaching Mode ──
            _buildLabel('Teaching Mode'),
            const SizedBox(height: 10),
            Row(
              children: List.generate(3, (i) {
                final sel = _selectedTeachingModes.contains(_teachingModes[i]);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        sel ? _selectedTeachingModes.remove(_teachingModes[i]) : _selectedTeachingModes.add(_teachingModes[i]);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 72,
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFFE3F2FD) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel ? AppColors.primaryBlue : const Color(0xFFDDDDDD),
                            width: sel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_teachingModeIcons[i], size: 22, color: sel ? AppColors.primaryBlue : const Color(0xFF757575)),
                            const SizedBox(height: 4),
                            Text(
                              _teachingModes[i],
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: sel ? AppColors.primaryBlue : const Color(0xFF757575)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ── Languages ──
            _buildLabel('Teaching Language'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _languages.map((l) {
                final sel = _selectedLanguages.contains(l);
                return GestureDetector(
                  onTap: () => setState(() => sel ? _selectedLanguages.remove(l) : _selectedLanguages.add(l)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: sel ? null : Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Text(
                      l,
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: sel ? Colors.white : const Color(0xFF2D2D2D)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  STEP 3 — Location, Fees & Bio
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildStep3(bool isTablet) {
    final hPad = isTablet ? MediaQuery.of(context).size.width * 0.12 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Location ──
            _buildLabel('Your Location'),
            Text('So parents nearby can find you', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF757575))),
            const SizedBox(height: 8),
            _buildInputField('City', 'e.g. Mumbai', Icons.location_city_outlined, _cityController, TextInputType.text, required: true),
            const SizedBox(height: 16),
            _buildInputField('Area', 'e.g. Andheri West', Icons.location_on_rounded, _areaController, TextInputType.text, required: true),
            const SizedBox(height: 8),
            Row(
              children: [
                // Use current location button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUsingCurrentLocation ? null : _useCurrentLocation,
                    icon: _isUsingCurrentLocation
                        ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))
                        : Icon(Icons.my_location_rounded, size: 16),
                    label: Text(
                      _isUsingCurrentLocation ? 'Getting location...' : 'Use current location',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Verify location button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isValidatingLocation ? null : _validateLocation,
                    icon: _isValidatingLocation
                        ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(_locationValidated ? Icons.check_circle_rounded : Icons.verified_outlined, size: 16),
                    label: Text(
                      _isValidatingLocation ? 'Verifying...' : _locationValidated ? 'Verified ✓' : 'Verify Location',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _locationValidated ? AppColors.primaryGreen : AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            // Location error
            if (_locationError != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFE57373)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_locationError!, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFE57373)))),
                  ],
                ),
              ),
            ],
            // Map preview (only shown after validation)
            if (_locationValidated && _validatedLat != null && _validatedLng != null) ...[
              const SizedBox(height: 12),
              _buildLocationMapPreview(isTablet),
            ],
            const SizedBox(height: 20),

            // ── Fees ──
            _buildLabel('Monthly Tuition Fees (₹)'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('₹', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  ),
                  Container(width: 1, height: 50, color: const Color(0xFFDDDDDD)),
                  Expanded(
                    child: TextFormField(
                      controller: _monthlyRateController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2D2D2D)),
                      decoration: InputDecoration(
                        hintText: 'e.g. 2000',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFBBBBBB)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter monthly fees' : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _quickFees.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _monthlyRateController.text = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('₹$f', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Bio ──
            _buildLabel('About You'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 250,
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF2D2D2D)),
                buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('$currentLength/$maxLength', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF757575))),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Share your teaching philosophy, experience highlights, and what makes you unique...',
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFBBBBBB)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Available Days ──
            _buildLabel('Available Days'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final sel = _selectedDays.contains(i);
                return GestureDetector(
                  onTap: () => setState(() => sel ? _selectedDays.remove(i) : _selectedDays.add(i)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38, height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      border: sel ? null : Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Text(
                      _dayLabels[i],
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? Colors.white : const Color(0xFF757575)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ── Time Slots ──
            _buildLabel('Preferred Timings'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _timeSlots.map((t) {
                final sel = _selectedTimeSlots.contains(t);
                return GestureDetector(
                  onTap: () => setState(() => sel ? _selectedTimeSlots.remove(t) : _selectedTimeSlots.add(t)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: sel ? null : Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Text(t, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: sel ? Colors.white : const Color(0xFF2D2D2D))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Social media (compact) ──
            _buildLabel('Social Media (Optional)'),
            const SizedBox(height: 8),
            _buildInputField('WhatsApp', 'WhatsApp number', Icons.phone_outlined, _whatsappController, TextInputType.phone),
            const SizedBox(height: 12),
            _buildInputField('Instagram', 'Instagram handle', Icons.camera_alt_outlined, _instagramController, TextInputType.text),
            const SizedBox(height: 12),
            _buildInputField('Facebook', 'Facebook profile', Icons.facebook_outlined, _facebookController, TextInputType.text),
            const SizedBox(height: 12),
            _buildInputField('Twitter', 'Twitter handle', Icons.alternate_email_outlined, _twitterController, TextInputType.text),
            const SizedBox(height: 20),

            // ── Upload progress (shown when saving) ──
            Consumer<TutorProvider>(
              builder: (context, tp, _) {
                if (tp.uploadProgress <= 0 || tp.uploadProgress >= 1) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        Icon(Icons.cloud_upload_rounded, color: AppColors.primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Uploading profile...', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D2D2D)))),
                        Text('${(tp.uploadProgress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                      ]),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: tp.uploadProgress,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  BOTTOM ACTION BAR
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildBottomBar(bool isTablet) {
    final isLastStep = _currentStep == 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back button
            Visibility(
              visible: _currentStep > 0,
              maintainSize: true, maintainAnimation: true, maintainState: true,
              child: OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                label: Text('Back', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: BorderSide(color: AppColors.primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const Spacer(),
            // Progress text
            Text(
              'Step ${_currentStep + 1} of 3',
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF757575)),
            ),
            const Spacer(),
            // Next / Submit
            Consumer<TutorProvider>(
              builder: (context, tp, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    onPressed: tp.isLoading ? null : _nextStep,
                    icon: tp.isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : null,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tp.isLoading ? 'Creating...' : isLastStep ? 'Create Profile' : 'Next',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        if (!tp.isLoading) ...[
                          const SizedBox(width: 4),
                          Icon(isLastStep ? Icons.check_circle_outline_rounded : Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastStep ? AppColors.primaryGreen : AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D2D2D)),
          children: required
              ? [TextSpan(text: ' *', style: GoogleFonts.poppins(color: const Color(0xFFE57373), fontWeight: FontWeight.w700))]
              : null,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
    TextInputType keyboardType, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2D2D2D)),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5)),
              prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFBBBBBB)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null
                : null,
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  IMAGE PICKER
  // ═════════════════════════════════════════════════════════════════════════════

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, maxHeight: 800, imageQuality: 85,
    );
    if (image != null) setState(() => _profileImage = File(image.path));
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  LOCATION VALIDATION & HELPERS
  // ═════════════════════════════════════════════════════════════════════════════

  Future<void> _validateLocation() async {
    final city = _cityController.text.trim();
    final area = _areaController.text.trim();
    if (city.isEmpty || area.isEmpty) {
      setState(() {
        _locationError = 'Please enter both City and Area first.';
        _locationValidated = false;
      });
      return;
    }
    setState(() {
      _isValidatingLocation = true;
      _locationError = null;
      _locationValidated = false;
    });
    final result = await TutorProvider.geocodeAddress('$area, $city');
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _validatedLat = result.lat;
        _validatedLng = result.lng;
        _locationValidated = true;
        _isValidatingLocation = false;
        _locationError = null;
      });
    } else {
      setState(() {
        _isValidatingLocation = false;
        _locationValidated = false;
        _locationError = 'Could not find this location. Please check the city and area names.';
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isUsingCurrentLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showErrorSnackBar('Please enable location services');
          setState(() => _isUsingCurrentLocation = false);
        }
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) {
          _showErrorSnackBar('Location permission is required');
          setState(() => _isUsingCurrentLocation = false);
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final place = await TutorProvider.reverseGeocodePosition(pos.latitude, pos.longitude);
      if (!mounted) return;
      if (place != null) {
        setState(() {
          _cityController.text = place.city;
          _areaController.text = place.area;
          _validatedLat = pos.latitude;
          _validatedLng = pos.longitude;
          _locationValidated = true;
          _locationError = null;
          _isUsingCurrentLocation = false;
        });
        _showSuccessSnackBar('Location detected: ${place.area}, ${place.city}');
      } else {
        setState(() {
          _validatedLat = pos.latitude;
          _validatedLng = pos.longitude;
          _locationValidated = true;
          _isUsingCurrentLocation = false;
        });
        _showInfoSnackBar('Got coordinates but could not determine address. Please fill in manually.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to get location. Please try again.');
        setState(() => _isUsingCurrentLocation = false);
      }
    }
  }

  Widget _buildLocationMapPreview(bool isTablet) {
    final previewHeight = isTablet ? 180.0 : 150.0;
    return Container(
      height: previewHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_validatedLat!, _validatedLng!),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('tutor_location'),
                position: LatLng(_validatedLat!, _validatedLng!),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            compassEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
            },
          ),
          // Verified badge overlay
          Positioned(
            top: 8, left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('Location verified', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SAVE PROFILE
  // ═════════════════════════════════════════════════════════════════════════════

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tutorProvider = Provider.of<TutorProvider>(context, listen: false);

    final user = authProvider.user;
    if (user == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    // Build time slots map from selected days/time slots
    final Map<String, String> timeSlots = {};
    for (final day in _selectedDays) {
      timeSlots[_dayLabels[day]] = _selectedTimeSlots.join(', ');
    }

    final tutor = TutorModel(
      personalInfo: PersonalInfo(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageUrl: '',
      ),
      professionalInfo: ProfessionalInfo(
        qualification: _qualificationController.text.trim(),
        qualificationImageUrl: '',
        experience: int.tryParse(_experienceController.text) ?? 0,
        subjects: _selectedSubjects,
        specializations: _selectedTeachingModes,
        monthlyRate: double.tryParse(_monthlyRateController.text) ?? 0,
      ),
      availability: AvailabilityInfo(
        standards: _selectedStandards,
        timeSlots: timeSlots,
      ),
      location: LocationInfo(
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        address: '${_areaController.text.trim()}, ${_cityController.text.trim()}',
        latitude: _validatedLat,
        longitude: _validatedLng,
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
      qualificationDoc: null,
    );

    if (success && mounted) {
      _showSuccessSnackBar('Profile created successfully!');
      Navigator.pop(context);
    } else if (mounted && tutorProvider.errorMessage != null) {
      _showErrorSnackBar(tutorProvider.errorMessage!);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SNACKBARS
  // ═════════════════════════════════════════════════════════════════════════════

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 13))),
      ]),
      backgroundColor: const Color(0xFFE57373),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 13))),
      ]),
      backgroundColor: AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 13))),
      ]),
      backgroundColor: AppColors.primaryBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
