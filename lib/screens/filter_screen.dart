// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../providers/theme_provider.dart';
import '../models/filter_model.dart';
import '../utils/app_colors.dart';
import '../widgets/filter_section.dart';
import '../widgets/price_range_slider.dart';

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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
      body: Column(
        children: [
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicFilters(),
                _buildAdvancedFilters(),
                _buildAvailabilityFilters(),
              ],
            ),
          ),
          _buildBottomActions(theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      title: Text(
        'Filter Tutors',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Consumer<FilterProvider>(
          builder: (context, filterProvider, child) {
            if (filterProvider.activeFilterCount > 0) {
              return TextButton(
                onPressed: () {
                  setState(() {
                    _tempFilter = const FilterModel();
                  });
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
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

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Basic'),
          Tab(text: 'Advanced'),
          Tab(text: 'Schedule'),
        ],
      ),
    );
  }

  Widget _buildBasicFilters() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationFilter(),
          const SizedBox(height: 24),
          _buildSubjectFilter(),
          const SizedBox(height: 24),
          _buildStandardsFilter(),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRangeFilter(),
          const SizedBox(height: 24),
          _buildExperienceFilter(),
          const SizedBox(height: 24),
          _buildRatingFilter(),
        ],
      ),
    );
  }

  Widget _buildAvailabilityFilters() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDaysFilter(),
          const SizedBox(height: 24),
          _buildTimeSlotFilter(),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return FilterSection(
          title: 'Location',
          child: Wrap(
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
        );
      },
    );
  }

  Widget _buildSubjectFilter() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return FilterSection(
          title: 'Subjects',
          child: Wrap(
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
        );
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    return FilterSection(
      title: 'Monthly Rate (₹${_tempFilter.priceRange.min.toInt()} - ₹${_tempFilter.priceRange.max.toInt()})',
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

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                context.read<FilterProvider>().updateFilter(_tempFilter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Additional filter methods...
  Widget _buildStandardsFilter() => const SizedBox(); // Implementation
  Widget _buildExperienceFilter() => const SizedBox(); // Implementation
  Widget _buildRatingFilter() => const SizedBox(); // Implementation
  Widget _buildDaysFilter() => const SizedBox(); // Implementation
  Widget _buildTimeSlotFilter() => const SizedBox(); // Implementation
}
