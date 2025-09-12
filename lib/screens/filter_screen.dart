// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../providers/theme_provider.dart';
import '../models/filter_model.dart';
import '../utils/app_colors.dart';
import '../widgets/filter_section.dart';
import '../widgets/filters/price_range_slider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late FilterModel _tempFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tempFilter = context.read<FilterProvider>().currentFilter;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark, isTablet, isDesktop),
      body: Column(
        children: [
          _buildTabBar(theme, isTablet, isDesktop),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicFilters(isTablet, isDesktop),
                _buildAdvancedFilters(isTablet, isDesktop),
                _buildAvailabilityFilters(isTablet, isDesktop),
              ],
            ),
          ),
          _buildBottomActions(theme, isTablet, isDesktop),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark, bool isTablet, bool isDesktop) {
    final titleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    
    return AppBar(
      elevation: 0,
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: theme.appBarTheme.foregroundColor ?? Colors.white,
      title: Text(
        'Filter Tutors',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: titleFontSize,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: isDesktop ? 28 : 24,
        ),
      ),
      actions: [
        Consumer<FilterProvider>(
          builder: (context, filterProvider, child) {
            if (filterProvider.activeFilterCount > 0) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilter = const FilterModel();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme, bool isTablet, bool isDesktop) {
    final tabPadding = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16, 
        vertical: isDesktop ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: EdgeInsets.all(isDesktop ? 6 : 4),
        tabs: [
          Tab(
            text: 'Basic',
            height: isDesktop ? 50 : isTablet ? 45 : 40,
          ),
          Tab(
            text: 'Advanced',
            height: isDesktop ? 50 : isTablet ? 45 : 40,
          ),
          Tab(
            text: 'Schedule',
            height: isDesktop ? 50 : isTablet ? 45 : 40,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicFilters(bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final spacing = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationFilter(),
          SizedBox(height: spacing),
          _buildSubjectFilter(),
          SizedBox(height: spacing),
          _buildStandardsFilter(),
          SizedBox(height: spacing * 2), // Extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters(bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final spacing = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRangeFilter(),
          SizedBox(height: spacing),
          _buildExperienceFilter(),
          SizedBox(height: spacing),
          _buildRatingFilter(),
          SizedBox(height: spacing),
          _buildQualificationFilter(),
          SizedBox(height: spacing * 2), // Extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildAvailabilityFilters(bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final spacing = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDaysFilter(),
          SizedBox(height: spacing),
          _buildTimeSlotFilter(),
          SizedBox(height: spacing * 2), // Extra padding at bottom
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return FilterSection(
          title: 'Preferred Locations',
          icon: Icons.location_on,
          showClearButton: _tempFilter.selectedLocations.isNotEmpty,
          onClear: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(selectedLocations: []);
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected locations display
              if (_tempFilter.selectedLocations.isNotEmpty) ...[
                Text(
                  'Selected: ${_tempFilter.selectedLocations.length} locations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tempFilter.selectedLocations.map((location) {
                    return Chip(
                      label: Text(location),
                      onDeleted: () {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(
                            selectedLocations: _tempFilter.selectedLocations
                                .where((l) => l != location)
                                .toList(),
                          );
                        });
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                      deleteIconColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Available locations
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filterProvider.availableLocations.map((location) {
                  final isSelected = _tempFilter.selectedLocations.contains(location);
                  return FilterChip(
                    label: Text(location),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tempFilter = _tempFilter.copyWith(
                            selectedLocations: [..._tempFilter.selectedLocations, location],
                          );
                        } else {
                          _tempFilter = _tempFilter.copyWith(
                            selectedLocations: _tempFilter.selectedLocations
                                .where((l) => l != location)
                                .toList(),
                          );
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectFilter() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return FilterSection(
          title: 'Subjects',
          icon: Icons.subject,
          showClearButton: _tempFilter.selectedSubjects.isNotEmpty,
          onClear: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(selectedSubjects: []);
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected subjects display
              if (_tempFilter.selectedSubjects.isNotEmpty) ...[
                Text(
                  'Selected: ${_tempFilter.selectedSubjects.length} subjects',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tempFilter.selectedSubjects.map((subject) {
                    return Chip(
                      label: Text(subject),
                      onDeleted: () {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(
                            selectedSubjects: _tempFilter.selectedSubjects
                                .where((s) => s != subject)
                                .toList(),
                          );
                        });
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                      deleteIconColor: Theme.of(context).colorScheme.secondary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Available subjects
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filterProvider.availableSubjects.map((subject) {
                  final isSelected = _tempFilter.selectedSubjects.contains(subject);
                  return FilterChip(
                    label: Text(subject),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tempFilter = _tempFilter.copyWith(
                            selectedSubjects: [..._tempFilter.selectedSubjects, subject],
                          );
                        } else {
                          _tempFilter = _tempFilter.copyWith(
                            selectedSubjects: _tempFilter.selectedSubjects
                                .where((s) => s != subject)
                                .toList(),
                          );
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.secondary,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStandardsFilter() {
    final standards = List.generate(12, (index) => index + 1);
    
    return FilterSection(
      title: 'Teaching Standards',
      icon: Icons.school,
      showClearButton: _tempFilter.selectedStandards.isNotEmpty,
      onClear: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(selectedStandards: []);
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tempFilter.selectedStandards.isNotEmpty) ...[
            Text(
              'Selected: ${_tempFilter.selectedStandards.map((s) => 'Std $s').join(', ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2,
            ),
            itemCount: standards.length,
            itemBuilder: (context, index) {
              final standard = standards[index];
              final isSelected = _tempFilter.selectedStandards.contains(standard);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _tempFilter = _tempFilter.copyWith(
                        selectedStandards: _tempFilter.selectedStandards
                            .where((s) => s != standard)
                            .toList(),
                      );
                    } else {
                      _tempFilter = _tempFilter.copyWith(
                        selectedStandards: [..._tempFilter.selectedStandards, standard],
                      );
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.tertiary 
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Std $standard',
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return FilterSection(
      title: 'Monthly Rate (₹${_tempFilter.priceRange.min.toInt()} - ₹${_tempFilter.priceRange.max.toInt()})',
      icon: Icons.currency_rupee,
      showClearButton: !_tempFilter.priceRange.isDefault,
      onClear: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(
            priceRange: const PriceRange(),
          );
        });
      },
      child: PriceRangeSlider(
        min: 0,
        max: 50000,
        values: RangeValues(_tempFilter.priceRange.min, _tempFilter.priceRange.max),
        onChanged: (values) {
          setState(() {
            _tempFilter = _tempFilter.copyWith(
              priceRange: PriceRange(min: values.start, max: values.end),
            );
          });
        },
      ),
    );
  }

  Widget _buildExperienceFilter() {
    return FilterSection(
      title: 'Experience (${_tempFilter.experienceRange.min} - ${_tempFilter.experienceRange.max} years)',
      icon: Icons.work_history,
      showClearButton: !_tempFilter.experienceRange.isDefault,
      onClear: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(
            experienceRange: const ExperienceRange(),
          );
        });
      },
      child: Column(
        children: [
          RangeSlider(
            values: RangeValues(
              _tempFilter.experienceRange.min.toDouble(),
              _tempFilter.experienceRange.max.toDouble(),
            ),
            min: 0,
            max: 30,
            divisions: 30,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            labels: RangeLabels(
              '${_tempFilter.experienceRange.min}y',
              '${_tempFilter.experienceRange.max}y',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _tempFilter = _tempFilter.copyWith(
                  experienceRange: ExperienceRange(
                    min: values.start.toInt(),
                    max: values.end.toInt(),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 8),
          // Experience presets
          Wrap(
            spacing: 8,
            children: [
              _buildExperiencePreset('Fresher (0-2y)', 0, 2),
              _buildExperiencePreset('Mid (3-7y)', 3, 7),
              _buildExperiencePreset('Senior (8-15y)', 8, 15),
              _buildExperiencePreset('Expert (15y+)', 15, 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencePreset(String label, int min, int max) {
    final isSelected = _tempFilter.experienceRange.min == min && _tempFilter.experienceRange.max == max;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(
            experienceRange: ExperienceRange(min: min, max: max),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return FilterSection(
      title: 'Minimum Rating',
      icon: Icons.star,
      showClearButton: _tempFilter.minRating > 0,
      onClear: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(minRating: 0.0);
        });
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final rating = (index + 1).toDouble();
              final isSelected = _tempFilter.minRating >= rating;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(
                      minRating: isSelected && _tempFilter.minRating == rating ? 0.0 : rating,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: isSelected ? Colors.white : Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${rating.toInt()}+',
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          if (_tempFilter.minRating > 0)
            Text(
              'Showing tutors with ${_tempFilter.minRating.toInt()}+ star ratings',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQualificationFilter() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return FilterSection(
          title: 'Qualifications',
          icon: Icons.workspace_premium,
          showClearButton: _tempFilter.selectedQualifications.isNotEmpty,
          onClear: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(selectedQualifications: []);
            });
          },
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterProvider.availableQualifications.map((qualification) {
              final isSelected = _tempFilter.selectedQualifications.contains(qualification);
              return FilterChip(
                label: Text(qualification),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _tempFilter = _tempFilter.copyWith(
                        selectedQualifications: [..._tempFilter.selectedQualifications, qualification],
                      );
                    } else {
                      _tempFilter = _tempFilter.copyWith(
                        selectedQualifications: _tempFilter.selectedQualifications
                            .where((q) => q != qualification)
                            .toList(),
                      );
                    }
                  });
                },
                selectedColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.tertiary,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDaysFilter() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return FilterSection(
          title: 'Available Days',
          icon: Icons.calendar_today,
          showClearButton: _tempFilter.availability.selectedDays.isNotEmpty,
          onClear: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(
                availability: AvailabilityFilter(
                  selectedDays: [],
                  timeRange: _tempFilter.availability.timeRange,
                ),
              );
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_tempFilter.availability.selectedDays.isNotEmpty) ...[
                Text(
                  'Selected: ${_tempFilter.availability.selectedDays.map((d) => d.substring(0, 3)).join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filterProvider.availableDays.map((day) {
                  final isSelected = _tempFilter.availability.selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day.substring(0, 3)), // Show short form
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        final selectedDays = List<String>.from(_tempFilter.availability.selectedDays);
                        if (selected) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                        _tempFilter = _tempFilter.copyWith(
                          availability: AvailabilityFilter(
                            selectedDays: selectedDays,
                            timeRange: _tempFilter.availability.timeRange,
                          ),
                        );
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.secondary,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotFilter() {
    return FilterSection(
      title: 'Preferred Time (${_tempFilter.availability.timeRange.startHour}:00 - ${_tempFilter.availability.timeRange.endHour}:00)',
      icon: Icons.access_time,
      showClearButton: _tempFilter.availability.timeRange.startHour != 6 || 
                       _tempFilter.availability.timeRange.endHour != 22,
      onClear: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(
            availability: AvailabilityFilter(
              selectedDays: _tempFilter.availability.selectedDays,
              timeRange: const TimeRange(),
            ),
          );
        });
      },
      child: Column(
        children: [
          RangeSlider(
            values: RangeValues(
              _tempFilter.availability.timeRange.startHour.toDouble(),
              _tempFilter.availability.timeRange.endHour.toDouble(),
            ),
            min: 6,
            max: 22,
            divisions: 16,
            activeColor: Theme.of(context).colorScheme.secondary,
            inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            labels: RangeLabels(
              '${_tempFilter.availability.timeRange.startHour}:00',
              '${_tempFilter.availability.timeRange.endHour}:00',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _tempFilter = _tempFilter.copyWith(
                  availability: AvailabilityFilter(
                    selectedDays: _tempFilter.availability.selectedDays,
                    timeRange: TimeRange(
                      startHour: values.start.toInt(),
                      endHour: values.end.toInt(),
                    ),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 8),
          // Time presets
          Wrap(
            spacing: 8,
            children: [
              _buildTimePreset('Morning', 6, 12),
              _buildTimePreset('Afternoon', 12, 16),
              _buildTimePreset('Evening', 16, 20),
              _buildTimePreset('Full Day', 6, 22),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePreset(String label, int startHour, int endHour) {
    final isSelected = _tempFilter.availability.timeRange.startHour == startHour && 
                      _tempFilter.availability.timeRange.endHour == endHour;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(
            availability: AvailabilityFilter(
              selectedDays: _tempFilter.availability.selectedDays,
              timeRange: TimeRange(startHour: startHour, endHour: endHour),
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.secondary 
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.secondary 
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme, bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final buttonHeight = isDesktop ? 52.0 : isTablet ? 48.0 : 44.0;
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                  ),
                  side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 20 : 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  context.read<FilterProvider>().updateFilter(_tempFilter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
