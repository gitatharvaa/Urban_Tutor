// lib/providers/filter_provider.dart
import 'package:flutter/material.dart';
import '../models/filter_model.dart';

class FilterProvider with ChangeNotifier {
  FilterModel _currentFilter = const FilterModel();
  bool _isFilterBottomSheetOpen = false;

  FilterModel get currentFilter => _currentFilter;
  bool get isFilterBottomSheetOpen => _isFilterBottomSheetOpen;
  bool get hasActiveFilters => _currentFilter.hasActiveFilters;

  // Available options for filters
  static const List<String> _availableSubjects = [
    'Mathematics', 'Science', 'English', 'Hindi', 'Physics', 
    'Chemistry', 'Biology', 'History', 'Geography', 'Economics',
    'Computer Science', 'Accounts', 'Social Studies', 'Sanskrit',
    'Art', 'Music', 'Physical Education', 'Environmental Science'
  ];

  static const List<String> _availableLocations = [
    'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad',
    'Pune', 'Ahmedabad', 'Surat', 'Jaipur', 'Lucknow', 'Kanpur',
    'Nagpur', 'Indore', 'Bhopal', 'Visakhapatnam', 'Pimpri-Chinchwad',
    'Patna', 'Vadodara', 'Ghaziabad', 'Ludhiana', 'Agra', 'Nashik',
    'Faridabad', 'Meerut', 'Rajkot', 'Kalyan-Dombivali', 'Vasai-Virar',
    'Varanasi', 'Srinagar', 'Aurangabad', 'Dhanbad', 'Amritsar',
    'Navi Mumbai', 'Allahabad', 'Howrah', 'Ranchi', 'Gwalior', 'Jabalpur'
  ];

  static const List<String> _availableQualifications = [
    'B.Ed', 'M.Ed', 'B.A', 'M.A', 'B.Sc', 'M.Sc', 'B.Tech', 'M.Tech',
    'PhD', 'Diploma', 'B.Com', 'M.Com', 'MBA', 'CA', 'CS', 'MBBS',
    'Engineering', 'Medical', 'Arts', 'Commerce', 'Science'
  ];

  // Getters for available options
  List<String> get availableSubjects => List.from(_availableSubjects);
  List<String> get availableLocations => List.from(_availableLocations);
  List<String> get availableQualifications => List.from(_availableQualifications);

  // Get available days
  List<String> get availableDays => [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
    'Friday', 'Saturday', 'Sunday'
  ];

  // Subject filters
  void toggleSubject(String subject) {
    final subjects = List<String>.from(_currentFilter.selectedSubjects);
    if (subjects.contains(subject)) {
      subjects.remove(subject);
    } else {
      subjects.add(subject);
    }
    _currentFilter = _currentFilter.copyWith(selectedSubjects: subjects);
    notifyListeners();
  }

  void setSubjects(List<String> subjects) {
    _currentFilter = _currentFilter.copyWith(selectedSubjects: subjects);
    notifyListeners();
  }

  // Location filters
  void toggleLocation(String location) {
    final locations = List<String>.from(_currentFilter.selectedLocations);
    if (locations.contains(location)) {
      locations.remove(location);
    } else {
      locations.add(location);
    }
    _currentFilter = _currentFilter.copyWith(selectedLocations: locations);
    notifyListeners();
  }

  void setLocations(List<String> locations) {
    _currentFilter = _currentFilter.copyWith(selectedLocations: locations);
    notifyListeners();
  }

  // Price range
  void setPriceRange(double min, double max) {
    _currentFilter = _currentFilter.copyWith(
      priceRange: PriceRange(min: min, max: max),
    );
    notifyListeners();
  }

  // Experience range
  void setExperienceRange(int min, int max) {
    _currentFilter = _currentFilter.copyWith(
      experienceRange: ExperienceRange(min: min, max: max),
    );
    notifyListeners();
  }

  // Standards filter
  void toggleStandard(int standard) {
    final standards = List<int>.from(_currentFilter.selectedStandards);
    if (standards.contains(standard)) {
      standards.remove(standard);
    } else {
      standards.add(standard);
    }
    _currentFilter = _currentFilter.copyWith(selectedStandards: standards);
    notifyListeners();
  }

  void setStandards(List<int> standards) {
    _currentFilter = _currentFilter.copyWith(selectedStandards: standards);
    notifyListeners();
  }

  // Rating filter
  void setMinRating(double rating) {
    _currentFilter = _currentFilter.copyWith(minRating: rating);
    notifyListeners();
  }

  // Qualification filter
  void toggleQualification(String qualification) {
    final qualifications = List<String>.from(_currentFilter.selectedQualifications);
    if (qualifications.contains(qualification)) {
      qualifications.remove(qualification);
    } else {
      qualifications.add(qualification);
    }
    _currentFilter = _currentFilter.copyWith(selectedQualifications: qualifications);
    notifyListeners();
  }

  void setQualifications(List<String> qualifications) {
    _currentFilter = _currentFilter.copyWith(selectedQualifications: qualifications);
    notifyListeners();
  }

  // Availability filter
  void setAvailability(AvailabilityFilter availability) {
    _currentFilter = _currentFilter.copyWith(availability: availability);
    notifyListeners();
  }

  void toggleAvailableDay(String day) {
    final selectedDays = List<String>.from(_currentFilter.availability.selectedDays);
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
    
    final newAvailability = AvailabilityFilter(
      selectedDays: selectedDays,
      timeRange: _currentFilter.availability.timeRange,
    );
    
    _currentFilter = _currentFilter.copyWith(availability: newAvailability);
    notifyListeners();
  }

  void setTimeRange(int startHour, int endHour) {
    final newAvailability = AvailabilityFilter(
      selectedDays: _currentFilter.availability.selectedDays,
      timeRange: TimeRange(startHour: startHour, endHour: endHour),
    );
    
    _currentFilter = _currentFilter.copyWith(availability: newAvailability);
    notifyListeners();
  }

  // Update entire filter (THIS WAS MISSING)
  void updateFilter(FilterModel newFilter) {
    _currentFilter = newFilter;
    notifyListeners();
  }

  // Clear all filters
  void clearAllFilters() {
    _currentFilter = const FilterModel();
    notifyListeners();
  }

  // Reset to default
  void resetFilters() {
    _currentFilter = const FilterModel();
    notifyListeners();
  }

  // Bottom sheet state
  void setFilterBottomSheetOpen(bool isOpen) {
    _isFilterBottomSheetOpen = isOpen;
    notifyListeners();
  }

  // Quick filter presets
  void applyQuickFilter(String type) {
    switch (type) {
      case 'nearby':
        // Apply location-based filter (you can customize this)
        break;
      case 'affordable':
        setPriceRange(0, 10000);
        break;
      case 'experienced':
        setExperienceRange(5, 30);
        setMinRating(4.0);
        break;
      case 'top_rated':
        setMinRating(4.5);
        break;
    }
  }

  // Get filter count
  int get activeFilterCount {
    int count = 0;
    if (_currentFilter.selectedSubjects.isNotEmpty) count++;
    if (_currentFilter.selectedLocations.isNotEmpty) count++;
    if (!_currentFilter.priceRange.isDefault) count++;
    if (!_currentFilter.experienceRange.isDefault) count++;
    if (_currentFilter.selectedStandards.isNotEmpty) count++;
    if (_currentFilter.minRating > 0) count++;
    if (_currentFilter.selectedQualifications.isNotEmpty) count++;
    if (_currentFilter.availability.selectedDays.isNotEmpty) count++;
    return count;
  }

  // Helper method to check if a specific filter type is active
  bool isSubjectFilterActive(String subject) {
    return _currentFilter.selectedSubjects.contains(subject);
  }

  bool isLocationFilterActive(String location) {
    return _currentFilter.selectedLocations.contains(location);
  }

  bool isStandardFilterActive(int standard) {
    return _currentFilter.selectedStandards.contains(standard);
  }

  bool isQualificationFilterActive(String qualification) {
    return _currentFilter.selectedQualifications.contains(qualification);
  }

  bool isDayFilterActive(String day) {
    return _currentFilter.availability.selectedDays.contains(day);
  }
}
