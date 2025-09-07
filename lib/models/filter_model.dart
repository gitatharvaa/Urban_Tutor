// lib/models/filter_model.dart
class FilterModel {
  final List<String> selectedSubjects;
  final List<String> selectedLocations;
  final PriceRange priceRange;
  final ExperienceRange experienceRange;
  final List<int> selectedStandards;
  final double minRating;
  final List<String> selectedQualifications;
  final AvailabilityFilter availability;

  const FilterModel({
    this.selectedSubjects = const [],
    this.selectedLocations = const [],
    this.priceRange = const PriceRange(),
    this.experienceRange = const ExperienceRange(),
    this.selectedStandards = const [],
    this.minRating = 0.0,
    this.selectedQualifications = const [],
    this.availability = const AvailabilityFilter(),
  });

  FilterModel copyWith({
    List<String>? selectedSubjects,
    List<String>? selectedLocations,
    PriceRange? priceRange,
    ExperienceRange? experienceRange,
    List<int>? selectedStandards,
    double? minRating,
    List<String>? selectedQualifications,
    AvailabilityFilter? availability,
  }) {
    return FilterModel(
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      priceRange: priceRange ?? this.priceRange,
      experienceRange: experienceRange ?? this.experienceRange,
      selectedStandards: selectedStandards ?? this.selectedStandards,
      minRating: minRating ?? this.minRating,
      selectedQualifications: selectedQualifications ?? this.selectedQualifications,
      availability: availability ?? this.availability,
    );
  }

  bool get hasActiveFilters =>
      selectedSubjects.isNotEmpty ||
      selectedLocations.isNotEmpty ||
      !priceRange.isDefault ||
      !experienceRange.isDefault ||
      selectedStandards.isNotEmpty ||
      minRating > 0 ||
      selectedQualifications.isNotEmpty;
}

class PriceRange {
  final double min;
  final double max;
  
  const PriceRange({this.min = 0, this.max = 50000});
  
  bool get isDefault => min == 0 && max == 50000;
}

class ExperienceRange {
  final int min;
  final int max;
  
  const ExperienceRange({this.min = 0, this.max = 30});
  
  bool get isDefault => min == 0 && max == 30;
}

class AvailabilityFilter {
  final List<String> selectedDays;
  final TimeRange timeRange;
  
  const AvailabilityFilter({
    this.selectedDays = const [],
    this.timeRange = const TimeRange(),
  });
}

class TimeRange {
  final int startHour;
  final int endHour;
  
  const TimeRange({this.startHour = 6, this.endHour = 22});
}
