/*
 * ═══════════════════════════════════════════════════════════════════════════
 * THEME MODE SELECTOR - Dark/Light/System Mode Toggle
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * FEATURES:
 * - Three-way toggle (Light/Dark/System)
 * - Visual feedback for selected mode
 * - Smooth animations
 * 
 * CONCEPTS:
 * - SegmentedButton: Multi-choice selector
 * - Icons for visual clarity
 * - State management with callbacks
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';

class ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onChanged;

  const ThemeModeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette),
                const SizedBox(width: 12),
                Text(
                  'Theme Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // ═══════════════════════════════════════════════════════════════════
            // SEGMENTEDBUTTON: Multi-choice selector
            // ═══════════════════════════════════════════════════════════════════
            // WHAT: Material 3 component for selecting one option from many
            // WHY: Better UX than dropdown for 2-4 options
            // WHEN: Mutually exclusive choices (theme, view mode, etc.)
            // 
            // HOW IT WORKS:
            // 1. User taps a segment
            // 2. onSelectionChanged called with new selection
            // 3. Parent updates state
            // 4. UI rebuilds with new selected segment
            // 
            // PROPERTIES:
            // - segments: List of ButtonSegment (options)
            // - selected: Set of currently selected values
            // - onSelectionChanged: Callback when selection changes
            // - showSelectedIcon: Show checkmark on selected
            // 
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.settings_suggest),
                ),
              ],
              selected: {currentMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                onChanged(newSelection.first);
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: 8),
            Text(
              _getThemeDescription(currentMode),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'App will always use light theme';
      case ThemeMode.dark:
        return 'App will always use dark theme';
      case ThemeMode.system:
        return 'App will follow system theme settings';
    }
  }
}
