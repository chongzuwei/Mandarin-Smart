import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AccessibilitySettingsScope.of(context).settings;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: AppBar(
            title: const Text('Accessibility'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Text Size',
                style: AppTheme.headingSmall,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Scale: ${settings.textScale.toStringAsFixed(1)}x',
                      style: AppTheme.bodyMedium,
                    ),

                    Slider(
                      value: settings.textScale,
                      min: 0.8,
                      max: 1.6,
                      divisions: 8,
                      onChanged: (value) {
                        settings.setTextScale(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Theme Mode',
                style: AppTheme.headingSmall,
              ),

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        settings.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Follow System'),
                      value: settings.themeMode == ThemeMode.system,
                      onChanged: (value) {
                        if (value) {
                          settings.setThemeMode(ThemeMode.system);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}