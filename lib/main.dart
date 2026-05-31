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
    // Continue anyway - Firebase may not be available on web
  }
  
  runApp(const MandarinSmartApp());
}

class MandarinSmartApp extends StatefulWidget {
  const MandarinSmartApp({super.key});

  @override
  State<MandarinSmartApp> createState() => _MandarinSmartAppState();
}

class _MandarinSmartAppState extends State<MandarinSmartApp> {
  final AccessibilitySettings _accessibilitySettings = AccessibilitySettings(
    textScale: 1.0,
    themeMode: ThemeMode.dark,
  );




  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _accessibilitySettings,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return AccessibilitySettingsScope(
          settings: _accessibilitySettings,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(_accessibilitySettings.textScale),
            ),
            child: MaterialApp(
              title: 'MandarinSmart',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _accessibilitySettings.themeMode,
              home: const LoginScreen(),
            ),
          ),
        );
      },
    );
  }
}


/// Very small dependency-free “scope” for accessing settings from widgets.
class AccessibilitySettingsScope extends InheritedWidget {
  const AccessibilitySettingsScope({
    super.key,
    required this.settings,
    required super.child,
  });

  final AccessibilitySettings settings;

  @override
  bool updateShouldNotify(covariant AccessibilitySettingsScope oldWidget) {
    return oldWidget.settings != settings;
  }

  static AccessibilitySettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AccessibilitySettingsScope>();
    assert(scope != null, 'AccessibilitySettingsScope not found in widget tree');
    return scope!.settings;
  }
}

