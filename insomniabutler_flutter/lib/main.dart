import 'package:insomniabutler_client/insomniabutler_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'screens/home_screen.dart';
import 'screens/new_home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'core/theme.dart';

import 'dart:convert'; // Added for json.decode

late final Client client;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Enable edge-to-edge display and set transparent system bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Default server URL (fallback to AWS production)
  String serverUrl =
      'http://insomniabutler-alb-475922987.us-east-1.elb.amazonaws.com/';

  // Try to load from assets/config.json
  try {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = json.decode(configString);
    if (config['apiUrl'] != null) {
      serverUrl = config['apiUrl'];
      // Ensure it ends with /
      if (!serverUrl.endsWith('/')) {
        serverUrl += '/';
      }
    }
    print('Connecting to server: $serverUrl');
  } catch (e) {
    print('Failed to load config, using default: $e');
  }

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // Show splash for a brief moment then transition to Flutter splash
  await Future.delayed(const Duration(milliseconds: 500));
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insomnia Butler',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppInitializer(),
    );
  }
}

/// Determines whether to show onboarding or home screen
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      _showOnboarding = !hasCompletedOnboarding;
      _isLoading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.bgMainGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Styled Logo
                Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.accentPrimary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPrimary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/logo/splash_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 48),

                // Minimal loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentPrimary.withOpacity(0.5),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: _completeOnboarding,
      );
    }

    return const NewHomeScreen();
  }
}
