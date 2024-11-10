import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ibadah_v2/models/theme_provider.dart';
import 'package:ibadah_v2/services/notification_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeOption = ref.watch(themeModeProvider);
    final colorScheme = ref.watch(colorProvider);
    final colorSchemeUI = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorSchemeUI.onSecondary,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorSchemeUI.onSecondary,
        forceMaterialTransparency: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            color: colorSchemeUI.primaryFixedDim,
          ),
        ),
        titleSpacing: 25,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Theme Mode', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                DropdownButton<ThemeModeOption>(
                  enableFeedback: true,
                  value: themeModeOption,
                  onChanged: (ThemeModeOption? newMode) {
                    if (newMode != null) {
                      ref.read(themeModeProvider.notifier).state = newMode;
                    }
                  },
                  items: ThemeModeOption.values.map((ThemeModeOption mode) {
                    return DropdownMenuItem<ThemeModeOption>(
                      value: mode,
                      child: Text(mode.toString().split('.').last,
                          style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Color Scheme Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Color Scheme', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                DropdownButton<Color>(
                  enableFeedback: true,
                  value: colorScheme,
                  onChanged: (Color? newColor) {
                    if (newColor != null) {
                      ref.read(colorProvider.notifier).state = newColor;
                    }
                  },
                  items: predefinedColors.entries.map((entry) {
                    return DropdownMenuItem<Color>(
                      value: entry.value,
                      child:
                          Text(entry.key, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      // Call testNotification when the button is pressed
                      NotificationService().testNotification();
                    },
                    child: const Text('Send Test Notification'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
