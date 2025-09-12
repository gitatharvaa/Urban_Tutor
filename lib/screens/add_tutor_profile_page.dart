import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'package:urban_tutor/widgets/profile_form_sections.dart';
import 'dart:io';
import '../providers/tutor_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class AddTutorProfilePage extends StatefulWidget {
  const AddTutorProfilePage({super.key});

  @override
  State<AddTutorProfilePage> createState() => _AddTutorProfilePageState();
}

class _AddTutorProfilePageState extends State<AddTutorProfilePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
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

  // State variables
  File? _profileImage;
  File? _qualificationDoc;
  List<String> _selectedSubjects = [];
  List<int> _selectedStandards = [];
  final ImagePicker _picker = ImagePicker();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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

  // Responsive helper methods
  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isTablet => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1024;
  
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: AppColors.educationalColorScheme,
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final expandedHeight = _isMobile ? 140.0 : _isTablet ? 160.0 : 180.0;
    final titleFontSize = _isMobile ? 18.0 : _isTablet ? 22.0 : 24.0;
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Create Tutor Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: titleFontSize,
            letterSpacing: 0.5,
          ),
        ),
        titlePadding: EdgeInsets.only(
          left: _getResponsivePadding(),
          bottom: 16,
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.9),
                AppColors.primaryGreen.withOpacity(0.4),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Responsive decorative elements
              Positioned(
                top: (_isMobile ? 10 : 20),
                right: (_isMobile ? 20 : 40),
                child: Container(
                  width: _isMobile ? 80 : 120,
                  height: _isMobile ? 80 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: _isMobile ? 20 : 40,
                right: _isMobile ? 10 : 20,
                child: Container(
                  width: _isMobile ? 40 : 60,
                  height: _isMobile ? 40 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: (_isMobile ? 8 : 15),
                left: (_isMobile ? 15 : 25),
                child: Container(
                  width: _isMobile ? 50 : 80,
                  height: _isMobile ? 50 : 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen.withOpacity(0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, 
            color: Colors.white, 
            size: _isMobile ? 18 : 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: _getResponsiveSpacing()),
          _buildWelcomeSection(),
          SizedBox(height: _getResponsiveSpacing()),
          ProfileFormSections(
            profileImage: _profileImage,
            qualificationDoc: _qualificationDoc,
            selectedSubjects: _selectedSubjects,
            selectedStandards: _selectedStandards,
            onProfileImagePicked: (file) => setState(() => _profileImage = file),
            onQualificationDocPicked: (file) => setState(() => _qualificationDoc = file),
            onSubjectsChanged: (subjects) => setState(() => _selectedSubjects = subjects),
            onStandardsChanged: (standards) => setState(() => _selectedStandards = standards),
            nameController: _nameController,
            emailController: _emailController,
            phoneController: _phoneController,
            qualificationController: _qualificationController,
            experienceController: _experienceController,
            cityController: _cityController,
            areaController: _areaController,
            monthlyRateController: _monthlyRateController,
            bioController: _bioController,
            whatsappController: _whatsappController,
            facebookController: _facebookController,
            instagramController: _instagramController,
            twitterController: _twitterController,
            picker: _picker,
          ),
          SizedBox(height: _getResponsiveSpacing() * 1.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding()),
            child: _buildSaveButton(),
          ),
          SizedBox(height: _getResponsiveSpacing() * 1.5),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final iconSize = _isMobile ? 28.0 : _isTablet ? 32.0 : 36.0;
    final titleFontSize = _isMobile ? 18.0 : _isTablet ? 20.0 : 22.0;
    final subtitleFontSize = _isMobile ? 13.0 : _isTablet ? 14.0 : 15.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getResponsivePadding()),
      padding: EdgeInsets.all(_isMobile ? 20 : _isTablet ? 24 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.08),
            AppColors.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: _isMobile 
        ? Column(
            children: [
              Container(
                padding: EdgeInsets.all(_isMobile ? 12 : 16),
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
                child: Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Build Your Teaching Profile',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your expertise and connect with students looking for quality education',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Container(
                padding: EdgeInsets.all(_isMobile ? 12 : 16),
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
                child: Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build Your Teaching Profile',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your expertise and connect with students looking for quality education',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSaveButton() {
    return Consumer<TutorProvider>(
      builder: (context, tutorProvider, child) {
        final buttonHeight = _isMobile ? 56.0 : _isTablet ? 60.0 : 64.0;
        final fontSize = _isMobile ? 16.0 : _isTablet ? 17.0 : 18.0;
        final iconSize = _isMobile ? 22.0 : _isTablet ? 24.0 : 26.0;
        
        return Column(
          children: [
            if (tutorProvider.uploadProgress > 0 &&
                tutorProvider.uploadProgress < 1)
              Container(
                margin: EdgeInsets.only(bottom: _getResponsiveSpacing()),
                padding: EdgeInsets.all(_isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cloud_upload_rounded,
                            color: AppColors.primaryBlue,
                            size: _isMobile ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: _isMobile ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uploading Profile',
                                style: TextStyle(
                                  fontSize: _isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please wait while we save your information...',
                                style: TextStyle(
                                  fontSize: _isMobile ? 12 : 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _isMobile ? 8 : 12, 
                            vertical: _isMobile ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(tutorProvider.uploadProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: _isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _isMobile ? 16 : 20),
                    LinearProgressIndicator(
                      value: tutorProvider.uploadProgress,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              height: buttonHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: tutorProvider.isLoading
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [AppColors.primaryBlue, AppColors.primaryGreen],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
                boxShadow: tutorProvider.isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.4),
                          blurRadius: _isMobile ? 15 : 20,
                          offset: Offset(0, _isMobile ? 6 : 10),
                        ),
                      ],
              ),
              child: ElevatedButton(
                onPressed: tutorProvider.isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_isMobile ? 16 : 20),
                  ),
                ),
                child: tutorProvider.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: _isMobile ? 20 : 24,
                            width: _isMobile ? 20 : 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: _isMobile ? 12 : 16),
                          Text(
                            'Creating Profile...',
                            style: TextStyle(
                              fontSize: _isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          SizedBox(width: _isMobile ? 8 : 12),
                          Text(
                            'Create My Profile',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjects.isEmpty) {
      _showErrorSnackBar('Please select at least one subject');
      return;
    }

    if (_selectedStandards.isEmpty) {
      _showErrorSnackBar('Please select at least one standard');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tutorProvider = Provider.of<TutorProvider>(context, listen: false);

    final user = authProvider.user;
    if (user == null) {
      _showErrorSnackBar('User not authenticated');
      return;
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
      _showSuccessSnackBar('Profile created successfully!');
      Navigator.pop(context);
    } else if (mounted && tutorProvider.errorMessage != null) {
      _showErrorSnackBar(tutorProvider.errorMessage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            SizedBox(width: _isMobile ? 8 : 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isMobile ? 12 : 16),
        ),
        margin: EdgeInsets.all(_getResponsivePadding()),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: _isMobile ? 8 : 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isMobile ? 12 : 16),
        ),
        margin: EdgeInsets.all(_getResponsivePadding()),
      ),
    );
  }
}
