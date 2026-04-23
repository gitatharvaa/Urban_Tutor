// lib/providers/tutor_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:urban_tutor/services/cloudinary_service.dart';
import 'package:geocoding/geocoding.dart';
import '../models/tutor_model.dart';
import '../models/filter_model.dart';
import '../services/tutor_service.dart';

class TutorProvider with ChangeNotifier {
  final TutorService _tutorService = TutorService();
  List<TutorModel> _tutors = [];
  List<TutorModel> _filteredTutors = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _uploadProgress = 0;
  FilterModel? _activeFilter;

  List<TutorModel> get tutors => _tutors;
  List<TutorModel> get filteredTutors => _filteredTutors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  FilterModel? get activeFilter => _activeFilter;

  bool _hasGeocoded = false;

  // Load all tutors
  void loadTutors() {
    _tutorService.getAllTutors().listen(
      (tutors) {
        _tutors = tutors;
        if (_activeFilter != null) {
          _applyFilterToTutors(_activeFilter!);
        } else {
          _filteredTutors = tutors;
        }
        notifyListeners();
        // Geocode once after first load
        if (!_hasGeocoded && tutors.isNotEmpty) {
          _hasGeocoded = true;
          geocodeTutors();
        }
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  /// Convert tutor area+city into lat/lng for map pins.
  /// Only processes tutors that don't already have coordinates.
  Future<void> geocodeTutors() async {
    bool changed = false;
    for (int i = 0; i < _tutors.length; i++) {
      final tutor = _tutors[i];
      if (tutor.location.latitude == null || tutor.location.longitude == null) {
        final addressStr = '${tutor.location.area}, ${tutor.location.city}'.trim();
        if (addressStr.isEmpty || addressStr == ',') continue;
        try {
          final locations = await locationFromAddress(addressStr);
          if (locations.isNotEmpty) {
            // Create a new LocationInfo with coordinates
            _tutors[i] = TutorModel(
              id: tutor.id,
              personalInfo: tutor.personalInfo,
              professionalInfo: tutor.professionalInfo,
              availability: tutor.availability,
              location: LocationInfo(
                city: tutor.location.city,
                area: tutor.location.area,
                address: tutor.location.address,
                latitude: locations.first.latitude,
                longitude: locations.first.longitude,
              ),
              socialMedia: tutor.socialMedia,
              ratings: tutor.ratings,
              metadata: tutor.metadata,
              bio: tutor.bio,
            );
            changed = true;
          }
        } catch (_) {
          // Silently skip if geocoding fails
        }
      }
    }
    if (changed) {
      if (_activeFilter != null) {
        _applyFilterToTutors(_activeFilter!);
      } else {
        _filteredTutors = List.from(_tutors);
      }
      notifyListeners();
    }
  }

  /// Validate and geocode a single address string.
  /// Returns a (lat, lng) record or null if geocoding fails.
  /// Used by the Add Tutor page for live location validation.
  static Future<({double lat, double lng})?> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return (lat: locations.first.latitude, lng: locations.first.longitude);
      }
    } catch (_) {
      // geocoding failed
    }
    return null;
  }

  /// Reverse geocode coordinates into a human-readable address.
  /// Returns (city, area) or null if reverse geocoding fails.
  static Future<({String city, String area})?> reverseGeocodePosition(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? p.administrativeArea ?? '';
        final area = p.subLocality ?? p.thoroughfare ?? p.name ?? '';
        return (city: city, area: area);
      }
    } catch (_) {
      // reverse geocoding failed
    }
    return null;
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

      // Geocode the address
      double? lat;
      double? lng;
      try {
        final addressStr = '${tutor.location.area}, ${tutor.location.city}'.trim();
        if (addressStr.isNotEmpty && addressStr != ',') {
          final locations = await locationFromAddress(addressStr);
          if (locations.isNotEmpty) {
            lat = locations.first.latitude;
            lng = locations.first.longitude;
          }
        }
      } catch (_) {
        // Silently skip if geocoding fails during profile creation
      }

      // Create updated tutor model with image URLs and coordinates
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
        location: LocationInfo(
          city: tutor.location.city,
          area: tutor.location.area,
          address: tutor.location.address,
          latitude: lat,
          longitude: lng,
        ),
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

  // Apply advanced filters
  void applyFilters(FilterModel filter) {
    _activeFilter = filter;
    _applyFilterToTutors(filter);
    notifyListeners();
  }

  void _applyFilterToTutors(FilterModel filter) {
    List<TutorModel> filtered = List.from(_tutors);

    // Subject filter
    if (filter.selectedSubjects.isNotEmpty) {
      filtered = filtered.where((tutor) {
        return filter.selectedSubjects.any((subject) =>
            tutor.professionalInfo.subjects.contains(subject));
      }).toList();
    }

    // Location filter
    if (filter.selectedLocations.isNotEmpty) {
      filtered = filtered.where((tutor) {
        return filter.selectedLocations.any((location) =>
            tutor.location.city.toLowerCase().contains(location.toLowerCase()) ||
            tutor.location.area.toLowerCase().contains(location.toLowerCase()));
      }).toList();
    }

    // Price range filter
    if (!filter.priceRange.isDefault) {
      filtered = filtered.where((tutor) {
        return tutor.professionalInfo.monthlyRate >= filter.priceRange.min &&
               tutor.professionalInfo.monthlyRate <= filter.priceRange.max;
      }).toList();
    }

    // Experience filter
    if (!filter.experienceRange.isDefault) {
      filtered = filtered.where((tutor) {
        return tutor.professionalInfo.experience >= filter.experienceRange.min &&
               tutor.professionalInfo.experience <= filter.experienceRange.max;
      }).toList();
    }

    // Rating filter
    if (filter.minRating > 0) {
      filtered = filtered.where((tutor) {
        return tutor.ratings.averageRating >= filter.minRating;
      }).toList();
    }

    // Standards filter
    if (filter.selectedStandards.isNotEmpty) {
      filtered = filtered.where((tutor) {
        return filter.selectedStandards.any((standard) =>
            tutor.availability.standards.contains(standard));
      }).toList();
    }

    // Qualification filter
    if (filter.selectedQualifications.isNotEmpty) {
      filtered = filtered.where((tutor) {
        return filter.selectedQualifications.any((qualification) =>
            tutor.professionalInfo.qualification.toLowerCase()
                .contains(qualification.toLowerCase()));
      }).toList();
    }

    _filteredTutors = filtered;
  }

  // Search tutors (legacy method for text search)
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

  // Filter tutors locally (legacy method for text search)
  void filterTutors(String query) {
    if (query.isEmpty) {
      if (_activeFilter != null) {
        _applyFilterToTutors(_activeFilter!);
      } else {
        _filteredTutors = _tutors;
      }
    } else {
      List<TutorModel> baseList = _activeFilter != null 
          ? _getFilteredTutors(_activeFilter!)
          : _tutors;
      
      _filteredTutors = baseList.where((tutor) {
        return tutor.personalInfo.fullName.toLowerCase().contains(query.toLowerCase()) ||
               tutor.professionalInfo.subjects.any((subject) =>
                   subject.toLowerCase().contains(query.toLowerCase())) ||
               tutor.location.city.toLowerCase().contains(query.toLowerCase()) ||
               tutor.location.area.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  List<TutorModel> _getFilteredTutors(FilterModel filter) {
    List<TutorModel> filtered = List.from(_tutors);
    
    // Apply the same filtering logic as _applyFilterToTutors
    if (filter.selectedSubjects.isNotEmpty) {
      filtered = filtered.where((tutor) {
        return filter.selectedSubjects.any((subject) =>
            tutor.professionalInfo.subjects.contains(subject));
      }).toList();
    }

    if (filter.selectedLocations.isNotEmpty) {
      filtered = filtered.where((tutor) {
        return filter.selectedLocations.any((location) =>
            tutor.location.city.toLowerCase().contains(location.toLowerCase()) ||
            tutor.location.area.toLowerCase().contains(location.toLowerCase()));
      }).toList();
    }

    if (!filter.priceRange.isDefault) {
      filtered = filtered.where((tutor) {
        return tutor.professionalInfo.monthlyRate >= filter.priceRange.min &&
               tutor.professionalInfo.monthlyRate <= filter.priceRange.max;
      }).toList();
    }

    if (!filter.experienceRange.isDefault) {
      filtered = filtered.where((tutor) {
        return tutor.professionalInfo.experience >= filter.experienceRange.min &&
               tutor.professionalInfo.experience <= filter.experienceRange.max;
      }).toList();
    }

    if (filter.minRating > 0) {
      filtered = filtered.where((tutor) {
        return tutor.ratings.averageRating >= filter.minRating;
      }).toList();
    }

    if (filter.selectedStandards.isNotEmpty) {
      filtered = filtered.where((tutor) {
        return filter.selectedStandards.any((standard) =>
            tutor.availability.standards.contains(standard));
      }).toList();
    }

    return filtered;
  }

  // Clear filters
  void clearFilters() {
    _activeFilter = null;
    _filteredTutors = _tutors;
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
