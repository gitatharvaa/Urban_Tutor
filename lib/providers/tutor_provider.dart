import 'dart:io';
import 'package:flutter/material.dart';
import 'package:urban_tutor/services/cloudinary_service.dart';
import '../models/tutor_model.dart';
import '../services/tutor_service.dart';

class TutorProvider with ChangeNotifier {
  final TutorService _tutorService = TutorService();

  List<TutorModel> _tutors = [];
  List<TutorModel> _filteredTutors = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _uploadProgress = 0;

  List<TutorModel> get tutors => _tutors;
  List<TutorModel> get filteredTutors => _filteredTutors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  // Load all tutors
  void loadTutors() {
    _tutorService.getAllTutors().listen(
      (tutors) {
        _tutors = tutors;
        _filteredTutors = tutors;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  // Add tutor profile with Cloudinary image upload
  Future<bool> addTutorProfile({
    required TutorModel tutor,
    File? profileImage,
    File? qualificationDoc,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      String profileImageUrl = '';
      String qualificationImageUrl = '';

      // Upload profile image to Cloudinary
      if (profileImage != null) {
        _setUploadProgress(0.3);
        profileImageUrl = await CloudinaryService.upload(
          profileImage,
          folder: 'urban_tutor/profile',
        );
      }

      // Upload qualification document to Cloudinary
      if (qualificationDoc != null) {
        _setUploadProgress(0.6);
        qualificationImageUrl = await CloudinaryService.upload(
          qualificationDoc,
          folder: 'urban_tutor/docs',
          isRaw: true,
        );
      }

      _setUploadProgress(0.8);

      // Create updated tutor model with image URLs
      final updatedTutor = TutorModel(
        personalInfo: PersonalInfo(
          fullName: tutor.personalInfo.fullName,
          email: tutor.personalInfo.email,
          phone: tutor.personalInfo.phone,
          profileImageUrl: profileImageUrl,
        ),
        professionalInfo: ProfessionalInfo(
          qualification: tutor.professionalInfo.qualification,
          qualificationImageUrl: qualificationImageUrl,
          experience: tutor.professionalInfo.experience,
          subjects: tutor.professionalInfo.subjects,
          specializations: tutor.professionalInfo.specializations,
          monthlyRate: tutor.professionalInfo.monthlyRate,
        ),
        availability: tutor.availability,
        location: tutor.location,
        socialMedia: tutor.socialMedia,
        ratings: tutor.ratings,
        metadata: tutor.metadata,
        bio: tutor.bio,
      );

      // Save to Firestore
      _setUploadProgress(1.0);
      await _tutorService.addTutorProfile(updatedTutor);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
      _setUploadProgress(0.0);
    }
  }

  // Search tutors
  Future<void> searchTutors({
    String? query,
    List<String>? subjects,
    String? location,
    double? maxRate,
    double? minRating,
  }) async {
    try {
      _setLoading(true);
      List<TutorModel> results = await _tutorService.searchTutors(
        query: query,
        subjects: subjects,
        location: location,
        maxRate: maxRate,
        minRating: minRating,
      );
      _filteredTutors = results;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Filter tutors locally
  void filterTutors(String query) {
    if (query.isEmpty) {
      _filteredTutors = _tutors;
    } else {
      _filteredTutors = _tutors.where((tutor) {
        return tutor.personalInfo.fullName.toLowerCase().contains(query.toLowerCase()) ||
               tutor.professionalInfo.subjects.any((subject) =>
                   subject.toLowerCase().contains(query.toLowerCase())) ||
               tutor.location.city.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void clearError() => _clearError();
}
