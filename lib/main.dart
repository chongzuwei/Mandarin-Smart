import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'state/accessibility_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MandarinSmartApp());
}

class MandarinSmartApp extends StatefulWidget {
  const MandarinSmartApp({super.key});

  @override
  State<MandarinSmartApp> createState() => _MandarinSmartAppState();
}

class _MandarinSmartAppState extends State<MandarinSmartApp> {
  final AccessibilitySettings _settings = AccessibilitySettings(
    textScale: 1.0,
    themeMode: ThemeMode.system,
  );

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    await _settings.loadSettings();
    if (mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _settings,
      builder: (context, child) {
        return AccessibilitySettingsScope(
          settings: _settings,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(_settings.textScale),
            ),
            child: MaterialApp(
              title: 'MandarinSmart',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _settings.themeMode,
              home: const LoginScreen(),
            ),
          ),
        );
      },
    );
  }
}

class AccessibilitySettingsScope extends InheritedWidget {
  const AccessibilitySettingsScope({
    super.key,
    required this.settings,
    required super.child,
  });

  final AccessibilitySettings settings;

  static AccessibilitySettingsScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AccessibilitySettingsScope>();

    assert(
        scope != null, 'AccessibilitySettingsScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AccessibilitySettingsScope oldWidget) {
    return oldWidget.settings != settings;
  }
}
