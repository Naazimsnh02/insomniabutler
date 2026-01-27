import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/health_data_service.dart';
import '../../services/sleep_sync_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../utils/haptic_helper.dart';

class HealthConnectionScreen extends StatefulWidget {
  final HealthDataService healthService;
  final SleepSyncService syncService;

  const HealthConnectionScreen({
    super.key,
    required this.healthService,
    required this.syncService,
  });

  @override
  State<HealthConnectionScreen> createState() => _HealthConnectionScreenState();
}

class _HealthConnectionScreenState extends State<HealthConnectionScreen> {
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() => _isLoading = true);
    try {
      final hasPermissions = await widget.healthService.hasPermissions();
      setState(() {
        _isConnected = hasPermissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _connectHealthData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final granted = await widget.healthService.requestPermissions();
      
      if (granted) {
        setState(() {
          _isConnected = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Successfully connected to health data'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Trigger initial sync
        _performInitialSync();
      } else {
        setState(() {
          _errorMessage = 'Permission denied. Please grant access in Settings.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _performInitialSync() async {
    try {
      final result = await widget.syncService.syncLastNDays(30);
      
      if (mounted && result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📥 Imported ${result.sessionsImported} sleep sessions',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('Error during initial sync: $e');
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _isConnected = false;
      _errorMessage = null;
    });

    await widget.syncService.clearSyncData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from health data'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformName = Platform.isIOS ? 'Apple HealthKit' : 'Health Connect';
    final platformIcon = Platform.isIOS ? Icons.favorite_rounded : Icons.health_and_safety_rounded;

    return Stack(
      children: [
        // Decorative background elements
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPrimary.withOpacity(0.04),
            ),
          ).animate().fadeIn(duration: 1200.ms),
        ),
        Positioned(
          bottom: 100,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLavender.withOpacity(0.03),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 1200.ms),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: const CircularProgressIndicator(color: AppColors.accentPrimary)
                                .animate()
                                .fadeIn(),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.containerPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                // Platform Icon & Name
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: (_isConnected ? AppColors.accentPrimary : AppColors.accentLavender)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: (_isConnected ? AppColors.accentPrimary : AppColors.accentLavender)
                                                .withOpacity(0.2),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (_isConnected ? AppColors.accentPrimary : AppColors.accentLavender)
                                                  .withOpacity(0.1),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            )
                                          ],
                                        ),
                                        child: Icon(
                                          platformIcon,
                                          size: 48,
                                          color: _isConnected ? AppColors.accentPrimary : AppColors.accentLavender,
                                        ),
                                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                                      const SizedBox(height: 20),
                                      Text(
                                        platformName,
                                        style: AppTextStyles.h1.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -1.0,
                                        ),
                                      ).animate().fadeIn(delay: 200.ms),
                                      const SizedBox(height: 8),
                                      // Connection Status Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: (_isConnected ? AppColors.accentPrimary : AppColors.textTertiary)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: (_isConnected ? AppColors.accentPrimary : AppColors.textTertiary)
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: _isConnected ? AppColors.accentPrimary : AppColors.textTertiary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _isConnected ? 'CONNECTED' : 'NOT CONNECTED',
                                              style: AppTextStyles.caption.copyWith(
                                                color: _isConnected ? AppColors.accentPrimary : AppColors.textTertiary,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(delay: 300.ms),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Error Message
                                if (_errorMessage != null) ...[
                                  GlassCard(
                                    color: AppColors.error.withOpacity(0.1),
                                    border: Border.all(color: AppColors.error.withOpacity(0.2)),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: AppColors.error),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().shake(),
                                  const SizedBox(height: 24),
                                ],

                                // Benefits Section
                                _buildBenefitsSection(),
                                const SizedBox(height: 24),

                                // Privacy Section
                                _buildPrivacySection(),
                                const SizedBox(height: 100), // Space for button
                              ],
                            ),
                          ),
                  ),
                  _buildBottomAction(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.lg,
        AppSpacing.containerPadding,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Text(
            'Health Connection',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimary.withOpacity(0),
            AppColors.bgPrimary,
          ],
        ),
      ),
      child: _isConnected
          ? GlassButton(
              text: 'Disconnect Service',
              onPressed: () {
                HapticHelper.mediumImpact();
                _disconnect();
              },
              icon: Icons.link_off_rounded,
            )
          : PrimaryButton(
              text: 'Connect Health Data',
              isLoading: _isLoading,
              onPressed: () {
                HapticHelper.mediumImpact();
                _connectHealthData();
              },
              icon: Icons.link_rounded,
            ),
    );
  }

  Widget _buildBenefitsSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Benefits'.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          _buildBenefitItem(
            Icons.bedtime_rounded,
            'Sync Automatically',
            'Your sleep data flows effortlessly from your device',
          ),
          _buildBenefitItem(
            Icons.insights_rounded,
            'Detailed Stages',
            'Deep, light, REM, and restoration analysis',
          ),
          _buildBenefitItem(
            Icons.favorite_rounded,
            'Vitals Analysis',
            'Track heart rate and HRV trends during sleep',
          ),
          _buildBenefitItem(
            Icons.analytics_rounded,
            'AI Optimization',
            'More data results in more precise sleep coaching',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      color: AppColors.accentCyan.withOpacity(0.04),
      border: Border.all(
        color: AppColors.accentCyan.withOpacity(0.15),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: AppColors.accentCyan, size: 18),
              const SizedBox(width: 12),
              Text(
                'PRIVACY FIRST',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 11,
                  color: AppColors.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your health data is processed locally and securely. You maintain full control over what is shared and can disconnect at any time.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }
}
