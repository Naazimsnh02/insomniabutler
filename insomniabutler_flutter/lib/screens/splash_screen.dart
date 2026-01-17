import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    // This is where you could load resources while the splash screen is displayed.
    await Future.delayed(const Duration(milliseconds: 500));
    FlutterNativeSplash.remove();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(title: 'Insomnia Butler'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with pulse animation
            Image.asset(
              'assets/images/logo.png',
              width: 180,
              height: 180,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                )
                .shimmer(
                  duration: 3000.ms,
                  color: AppColors.accentPurple.withOpacity(0.3),
                ),
            
            const SizedBox(height: 40),
            
            // App Name with Gradient
            ShaderMask(
              shaderCallback: (bounds) => AppColors.logoGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text(
                'Insomnia Butler',
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Your AI Thought Partner',
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
