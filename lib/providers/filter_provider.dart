// lib/providers/filter_provider.dart
import 'package:flutter/material.dart';
import '../models/filter_model.dart';
import '../models/tutor_model.dart';
import '../services/tutor_service.dart';

class FilterProvider with ChangeNotifier {
  FilterModel _currentFilter = const FilterModel();
  List<TutorModel> _originalTutors = [];
  List<TutorModel> _filteredTutors = [];
  List<String> _availableLocations = [];
  List<String> _availableSubjects = [];
  bool _isLoading = false;

  // Getters
  FilterModel get currentFilter => _currentFilter;
  List<TutorModel> get filteredTutors => _filteredTutors;
  List<String> get availableLocations => _availableLocations;
  List<String> get availableSubjects => _availableSubjects;
  bool get isLoading => _isLoading;
  int get activeFilterCount => _getActiveFilterCount();

  void setTutors(List<TutorModel> tutors) {
    _originalTutors = tutors;
    _extractFilterOptions();
    _applyFilters();
  }

  void updateFilter(FilterModel newFilter) {
    _currentFilter = newFilter;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _currentFilter = const FilterModel();
    _filteredTutors = List.from(_originalTutors);
    notifyListeners();
  }

  void _extractFilterOptions() {
    final locations = <String>{};
    final subjects = <String>{};

    for (final tutor in _originalTutors) {
      locations.add(tutor.location.city);
      subjects.addAll(tutor.professionalInfo.subjects);
    }

    _availableLocations = locations.toList()..sort();
    _availableSubjects = subjects.toList()..sort();
  }

  void _applyFilters() {
    _isLoading = true;
    notifyListeners();

    _filteredTutors = _originalTutors.where((tutor) {
      // Location filter
      if (_currentFilter.selectedLocations.isNotEmpty &&
          !_currentFilter.selectedLocations.contains(tutor.location.city)) {
        return false;
      }

      // Subject filter
      if (_currentFilter.selectedSubjects.isNotEmpty &&
          !tutor.professionalInfo.subjects
              .any((subject) => _currentFilter.selectedSubjects.contains(subject))) {
        return false;
      }

      // Price range filter
      final price = tutor.professionalInfo.monthlyRate;
      if (price < _currentFilter.priceRange.min ||
          price > _currentFilter.priceRange.max) {
        return false;
      }

      // Experience filter
      final experience = tutor.professionalInfo.experience;
      if (experience < _currentFilter.experienceRange.min ||
          experience > _currentFilter.experienceRange.max) {
        return false;
      }

      // Standards filter
      if (_currentFilter.selectedStandards.isNotEmpty &&
          !tutor.availability.standards
              .any((std) => _currentFilter.selectedStandards.contains(std))) {
        return false;
      }

      // Rating filter
      if (tutor.ratings.averageRating < _currentFilter.minRating) {
        return false;
      }

      return true;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_currentFilter.selectedSubjects.isNotEmpty) count++;
    if (_currentFilter.selectedLocations.isNotEmpty) count++;
    if (!_currentFilter.priceRange.isDefault) count++;
    if (!_currentFilter.experienceRange.isDefault) count++;
    if (_currentFilter.selectedStandards.isNotEmpty) count++;
    if (_currentFilter.minRating > 0) count++;
    return count;
  }
}
