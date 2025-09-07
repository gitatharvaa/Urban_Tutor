// lib/widgets/filter_chips.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FilterChips extends StatelessWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;
  final String? title;
  final int? maxSelection;
  final bool allowMultipleSelection;
  final Color? selectedColor;
  final Color? checkmarkColor;

  const FilterChips({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.title,
    this.maxSelection,
    this.allowMultipleSelection = true,
    this.selectedColor,
    this.checkmarkColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: allowMultipleSelection
                  ? (selected) => _handleMultipleSelection(selected, item)
                  : (selected) => _handleSingleSelection(selected, item),
              selectedColor: selectedColor ?? 
                  theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: checkmarkColor ?? 
                  theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected 
                    ? FontWeight.w600 
                    : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              showCheckmark: true,
            );
          }).toList(),
        ),
        if (selectedItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${selectedItems.length} selected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  void _handleMultipleSelection(bool selected, String item) {
    final newSelection = List<String>.from(selectedItems);
    
    if (selected) {
      // Check max selection limit
      if (maxSelection != null && newSelection.length >= maxSelection!) {
        return; // Don't add if limit reached
      }
      newSelection.add(item);
    } else {
      newSelection.remove(item);
    }
    
    onSelectionChanged(newSelection);
  }

  void _handleSingleSelection(bool selected, String item) {
    if (selected) {
      onSelectionChanged([item]);
    } else {
      onSelectionChanged([]);
    }
  }
}
