import 'package:insomniabutler_client/insomniabutler_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'screens/new_home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'core/theme.dart';
import 'screens/chat/chat_history_screen.dart';
import 'screens/insomnia_butler_screen.dart';
import 'screens/insomnia_butler_screen.dart';
import 'services/account_settings_service.dart';
import 'package:installed_apps/installed_apps.dart';
import 'services/notification_service.dart';
import 'services/distraction_monitor_service.dart';

import 'dart:convert'; // Added for json.decode
import 'dart:async'; // Added for unawaited

late final Client client;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize background audio. Must be awaited before AudioPlayer is used.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint('JustAudioBackground init error: $e');
  }

  // Initialize notifications
  await NotificationService.initialize();

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

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // Try to load custom config asynchronously without blocking main flow
  unawaited(
    rootBundle
        .loadString('assets/config.json')
        .then((configString) {
          try {
            final config = json.decode(configString);
            if (config['apiUrl'] != null) {
              String newUrl = config['apiUrl'];
              if (!newUrl.endsWith('/')) newUrl += '/';
              // Note: client.host or similar might need updating if serverpod client supports it
              // For now we just print it. Usually serverUrl is set at creation.
              debugPrint('Config loaded. API URL: $newUrl');
            }
          } catch (e) {
            debugPrint('Error parsing config: $e');
          }
        })
        .catchError((e) {
          debugPrint('Config not found or error loading: $e');
        }),
  );

  // Remove splash as soon as basic initialization is done
  FlutterNativeSplash.remove();

  runApp(const MyApp());
  
  // Start the distraction monitor service
  DistractionMonitorService.instance.start();
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
      routes: {
        '/chat_history': (context) => const ChatHistoryScreen(),
        '/butler': (context) => const InsomniaButlerScreen(),
      },
    );
  }
}

/// Determines whether to show onboarding or home screen
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

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
