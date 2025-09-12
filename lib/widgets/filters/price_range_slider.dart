// lib/widgets/filters/price_range_slider.dart
import 'package:flutter/material.dart';

class PriceRangeSlider extends StatefulWidget {
  final double min;
  final double max;
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;
  final int? divisions;
  final String? currency;

  const PriceRangeSlider({
    super.key,
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
    this.divisions,
    this.currency = '₹',
  });

  @override
  State<PriceRangeSlider> createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {
  late RangeValues _currentValues;

  @override
  void initState() {
    super.initState();
    _currentValues = widget.values;
  }

  @override
  void didUpdateWidget(PriceRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _currentValues = widget.values;
    }
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '${widget.currency}${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '${widget.currency}${(price / 1000).toStringAsFixed(0)}k';
    } else {
      return '${widget.currency}${price.toInt()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    return Column(
      children: [
        // Price display
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minimum price
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: isDesktop ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPrice(_currentValues.start),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Separator
              Container(
                height: 2,
                width: 24,
                color: theme.dividerColor,
              ),

              // Maximum price
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: isDesktop ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Max',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPrice(_currentValues.end),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isDesktop ? 24 : 16),

        // Range Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: isDesktop ? 6 : 4,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isDesktop ? 12 : 10,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: isDesktop ? 24 : 20,
            ),
            rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
            valueIndicatorTextStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: RangeSlider(
            values: _currentValues,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions ?? ((widget.max - widget.min) / 1000).round(),
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.outline.withOpacity(0.3),
            labels: RangeLabels(
              _formatPrice(_currentValues.start),
              _formatPrice(_currentValues.end),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentValues = values;
              });
              widget.onChanged(values);
            },
          ),
        ),

        SizedBox(height: isDesktop ? 16 : 12),

        // Quick preset buttons
        Wrap(
          spacing: isDesktop ? 12 : 8,
          runSpacing: isDesktop ? 8 : 6,
          children: _buildPresetButtons(theme, isDesktop),
        ),
      ],
    );
  }

  List<Widget> _buildPresetButtons(ThemeData theme, bool isDesktop) {
    final presets = [
      {'label': 'Under 5k', 'min': widget.min, 'max': 5000.0},
      {'label': '5k-15k', 'min': 5000.0, 'max': 15000.0},
      {'label': '15k-30k', 'min': 15000.0, 'max': 30000.0},
      {'label': 'Above 30k', 'min': 30000.0, 'max': widget.max},
    ];

    return presets.map((preset) {
      final min = preset['min'] as double;
      final max = preset['max'] as double;
      final isSelected = _currentValues.start == min && _currentValues.end == max;

      return GestureDetector(
        onTap: () {
          final newValues = RangeValues(min, max);
          setState(() {
            _currentValues = newValues;
          });
          widget.onChanged(newValues);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12,
            vertical: isDesktop ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Text(
            preset['label'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected 
                  ? Colors.white 
                  : theme.colorScheme.onSurface,
              fontSize: isDesktop ? 13 : 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    }).toList();
  }
}
