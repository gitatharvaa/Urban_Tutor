// lib/widgets/location_selector.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LocationSelector extends StatefulWidget {
  final List<String> availableLocations;
  final List<String> selectedLocations;
  final ValueChanged<List<String>> onSelectionChanged;
  final String? hintText;

  const LocationSelector({
    super.key,
    required this.availableLocations,
    required this.selectedLocations,
    required this.onSelectionChanged,
    this.hintText,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredLocations = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filteredLocations = widget.availableLocations;
    _searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLocations = widget.availableLocations
          .where((location) => location.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected locations display
          if (widget.selectedLocations.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.selectedLocations.map((location) {
                  return Chip(
                    label: Text(location),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onDeleted: () {
                      final newSelection = List<String>.from(widget.selectedLocations);
                      newSelection.remove(location);
                      widget.onSelectionChanged(newSelection);
                    },
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ),

          // Search and expand button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selectedLocations.isEmpty
                          ? (widget.hintText ?? 'Select locations')
                          : '${widget.selectedLocations.length} location(s) selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: widget.selectedLocations.isEmpty
                            ? theme.colorScheme.onSurface.withOpacity(0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),

          // Expandable location list
          if (_isExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search locations...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  // Location list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        final isSelected = widget.selectedLocations.contains(location);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (bool? selected) {
                            final newSelection = List<String>.from(widget.selectedLocations);
                            if (selected == true) {
                              newSelection.add(location);
                            } else {
                              newSelection.remove(location);
                            }
                            widget.onSelectionChanged(newSelection);
                          },
                          title: Text(location),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          activeColor: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
