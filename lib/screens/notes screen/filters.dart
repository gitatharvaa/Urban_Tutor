import 'package:flutter/material.dart';

void showFilterBottomSheet({
  required BuildContext context,
  required String selectedDifficulty,
  required ValueChanged<String?> onDifficultyChanged,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Difficulty Level'),
              DropdownButton<String>(
                value: selectedDifficulty,
                items: ['All', 'Easy', 'Medium', 'Advanced'].map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: onDifficultyChanged,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
