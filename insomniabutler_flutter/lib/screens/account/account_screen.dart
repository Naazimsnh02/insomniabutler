import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../services/user_service.dart';
import '../../services/account_settings_service.dart';
import '../../utils/haptic_helper.dart';
import '../../main.dart';
import '../onboarding/onboarding_screen.dart';
import '../new_home_screen.dart';
import '../journal/widgets/journal_skeleton.dart';

/// Account & Settings Screen
/// Provides comprehensive account management, app settings, and user preferences
class AccountScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onDataChanged;

  const AccountScreen({super.key, this.isTab = true, this.onDataChanged});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _userName = 'User';
  String _userEmail = '';
  DateTime? _accountCreatedAt;
  int _totalSessions = 0;
  int _totalJournalEntries = 0;
  int _currentStreak = 0;
  String _appVersion = '';

  // Settings state
  bool _bedtimeNotifications = true;
  bool _insightsNotifications = true;
  bool _journalNotifications = true;
  bool _hapticsEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _autoStartTracking = false;

  bool _isLoading = true;
  Map<String, dynamic>? _cachedStats;

  @override
  void initState() {
    super.initState();
    _loadFromCache();
    _loadData();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('user_account_stats');
      final name = await UserService.getCachedUserName();
      
      if (statsJson != null || name.isNotEmpty) {
        setState(() {
          if (statsJson != null) _cachedStats = jsonDecode(statsJson);
          _userName = name;
        });
      }
    } catch (e) {
      debugPrint('Error loading account cache: $e');
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_account_stats', jsonEncode(stats));
    } catch (e) {
      debugPrint('Error saving account cache: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 1. Fetch Basic Info & Version
      final packageInfoFuture = PackageInfo.fromPlatform();
      final userFuture = UserService.getCurrentUser();
      
      // 2. Fetch Settings
      final settingsFutures = Future.wait([
        AccountSettingsService.getBedtimeNotifications(),
        AccountSettingsService.getInsightsNotifications(),
        AccountSettingsService.getJournalNotifications(),
        AccountSettingsService.getHapticsEnabled(),
        AccountSettingsService.getSoundEffectsEnabled(),
        AccountSettingsService.getAutoStartTracking(),
      ]);

      // 3. Fetch Stats
      final statsFuture = client.auth.getUserStats(userId);

      // Execute all in parallel for performance
      final results = await Future.wait([
        userFuture,
        packageInfoFuture,
        settingsFutures,
        statsFuture,
      ]);

      final user = results[0] as dynamic; // User?
      final packageInfo = results[1] as PackageInfo;
      final settings = results[2] as List<bool>;
      final stats = results[3] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _userName = user?.name ?? _userName;
          _userEmail = user?.email ?? '';
          _accountCreatedAt = user?.createdAt;
          
          _totalSessions = stats['totalSleepSessions'] ?? 0;
          _totalJournalEntries = stats['totalJournalEntries'] ?? 0;
          _currentStreak = stats['currentStreak'] ?? 0;
          _cachedStats = stats;

          _bedtimeNotifications = settings[0];
          _insightsNotifications = settings[1];
          _journalNotifications = settings[2];
          _hapticsEnabled = settings[3];
          _soundEffectsEnabled = settings[4];
          _autoStartTracking = settings[5];
          
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
          _isLoading = false;
        });
        _saveToCache(stats);
      }
    } catch (e) {
      debugPrint('Error loading account data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getInitials() {
    if (_userName.isEmpty) return 'U';
    final parts = _userName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _userName[0].toUpperCase();
  }

  String _getAccountAge() {
    if (_accountCreatedAt == null) return 'New';
    final days = DateTime.now().difference(_accountCreatedAt!).inDays;
    if (days < 7) return '$days days';
    if (days < 30) return '${(days / 7).floor()} weeks';
    if (days < 365) return '${(days / 30).floor()} months';
    return '${(days / 365).floor()} years';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userEmail.isEmpty) {
      return _buildSkeletonBody();
    }

    return Stack(
      children: [
        // Decorative background elements
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPrimary.withOpacity(0.05),
            ),
          ).animate().fadeIn(duration: 1200.ms),
        ),
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLavender.withOpacity(0.03),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 1200.ms),
        ),

        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl * 1.5),
                    _buildProfileHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildStatsRow(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Settings Sections
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader('Sleep Preferences'),
                  const SizedBox(height: AppSpacing.md),
                  _buildSleepPreferences(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Notifications'),
                  const SizedBox(height: AppSpacing.md),
                  _buildNotificationSettings(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Display & Sound'),
                  const SizedBox(height: AppSpacing.md),
                  _buildDisplaySettings(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Data & Privacy'),
                  const SizedBox(height: AppSpacing.md),
                  _buildDataPrivacy(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Support & About'),
                  const SizedBox(height: AppSpacing.md),
                  _buildSupportAbout(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Developer Tools'),
                  const SizedBox(height: AppSpacing.md),
                  _buildDevTools(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildLogoutButton(),
                  const SizedBox(height: AppSpacing.xxl),
                  const SizedBox(height: 100), // Bottom nav spacing
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar with glow
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPrimary.withOpacity(0.1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 3.seconds,
                ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientPrimary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _getInitials(),
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Name & Email
        Text(
          _userName,
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userEmail,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 16),

        // Account age badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentPrimary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 14,
                color: AppColors.accentPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Member for ${_getAccountAge()}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatsRow() {
    final stats = _cachedStats ?? {
      'totalSleepSessions': _totalSessions,
      'totalJournalEntries': _totalJournalEntries,
      'currentStreak': _currentStreak,
    };

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '🌙',
            '${stats['totalSleepSessions'] ?? 0}',
            'Sleep',
            AppColors.accentPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            '📔',
            '${stats['totalJournalEntries'] ?? 0}',
            'Journal',
            AppColors.accentLavender,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            '🔥',
            '${stats['currentStreak'] ?? 0}',
            'Streak',
            const Color(0xFFFFB156), // Warm Amber
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1.5,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSleepPreferences() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.bedtime_rounded,
            title: 'Sleep Goal',
            subtitle: '8 hours per night',
            iconColor: AppColors.accentPrimary,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onTap: () {
              HapticHelper.lightImpact();
              _showSleepGoalDialog();
            },
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.alarm_rounded,
            title: 'Preferred Bedtime',
            subtitle: '11:00 PM',
            iconColor: AppColors.accentLavender,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onTap: () {
              HapticHelper.lightImpact();
              _showBedtimeDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.notifications_rounded,
            title: 'Bedtime Reminders',
            subtitle: 'Get reminded when it\'s time for bed',
            iconColor: const Color(0xFF64B5F6),
            value: _bedtimeNotifications,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setBedtimeNotifications(value);
              setState(() => _bedtimeNotifications = value);
            },
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.insights_rounded,
            title: 'Sleep Insights',
            subtitle: 'Receive personalized sleep insights',
            iconColor: const Color(0xFF81C784),
            value: _insightsNotifications,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setInsightsNotifications(value);
              setState(() => _insightsNotifications = value);
            },
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.auto_stories_rounded,
            title: 'Journal Prompts',
            subtitle: 'Daily journal writing reminders',
            iconColor: const Color(0xFFFFD54F),
            value: _journalNotifications,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setJournalNotifications(value);
              setState(() => _journalNotifications = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Feel vibrations when interacting',
            iconColor: const Color(0xFFBA68C8),
            value: _hapticsEnabled,
            onChanged: (value) async {
              if (value) await HapticHelper.lightImpact();
              await AccountSettingsService.setHapticsEnabled(value);
              setState(() => _hapticsEnabled = value);
            },
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.volume_up_rounded,
            title: 'Sound Effects',
            subtitle: 'Play sounds for interactions',
            iconColor: const Color(0xFF4DB6AC),
            value: _soundEffectsEnabled,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setSoundEffectsEnabled(value);
              setState(() => _soundEffectsEnabled = value);
            },
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.auto_awesome_rounded,
            title: 'Auto-Start Tracking',
            subtitle: 'Automatically track sleep at bedtime',
            iconColor: const Color(0xFF90A4AE),
            value: _autoStartTracking,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setAutoStartTracking(value);
              setState(() => _autoStartTracking = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacy() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.download_rounded,
            title: 'Export Sleep Data',
            subtitle: 'Download your data as CSV',
            iconColor: const Color(0xFF7986CB),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onTap: () {
              HapticHelper.lightImpact();
              _showExportDialog();
            },
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            iconColor: const Color(0xFFE57373),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onTap: () {
              HapticHelper.lightImpact();
              _showClearCacheDialog();
            },
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            iconColor: AppColors.accentError,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.accentError,
              size: 20,
            ),
            titleColor: AppColors.accentError,
            onTap: () {
              HapticHelper.mediumImpact();
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportAbout() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: _appVersion,
            iconColor: const Color(0xFFD4E157),
            trailing: const SizedBox.shrink(),
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle: 'naazimsnh02@gmail.com',
            iconColor: const Color(0xFF4FC3F7),
            trailing: const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
            onTap: () {
              HapticHelper.lightImpact();
              _launchEmail();
            },
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.article_outlined,
            title: 'About Insomnia Butler',
            subtitle: 'Learn more about the app',
            iconColor: const Color(0xFFF06292),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onTap: () {
              HapticHelper.lightImpact();
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDevTools() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.analytics_rounded,
            title: 'Generate Realistic Data',
            subtitle: 'Last 30 days of sleep & journal data',
            iconColor: AppColors.accentPrimary,
            trailing: const Icon(
              Icons.bolt_rounded,
              color: AppColors.accentPrimary,
              size: 20,
            ),
            onTap: () {
              HapticHelper.heavyImpact();
              _showGenerateDataDialog();
            },
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.delete_forever_rounded,
            title: 'Clear All Data',
            subtitle: 'Delete all sleep & journal records',
            iconColor: AppColors.accentError,
            trailing: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.accentError,
              size: 20,
            ),
            onTap: () {
              HapticHelper.heavyImpact();
              _showClearDataDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Divider(
        color: Colors.white.withOpacity(0.05),
        height: 1,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.accentError.withOpacity(0.15),
            AppColors.accentError.withOpacity(0.05),
          ],
        ),
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        borderRadius: 24,
        color: Colors.transparent,
        border: Border.all(
          color: AppColors.accentError.withOpacity(0.2),
        ),
        onTap: () {
          HapticHelper.mediumImpact();
          _showLogoutDialog();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.accentError,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Logout Account',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.accentError,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    ); // Removed animation here
  }

  Widget _buildSkeletonBody() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl * 1.5),
          // Profile Skeleton
          Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white10),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 12),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            )),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white10),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          )).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white10, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required Color iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentPrimary,
            activeTrackColor: AppColors.accentPrimary.withOpacity(0.2),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: Colors.white.withOpacity(0.05),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showSleepGoalDialog() {
    final goals = ['6 hours', '7 hours', '8 hours', '9 hours', '10 hours'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Sleep Goal', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals
              .map(
                (goal) => ListTile(
                  title: Text(
                    goal,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () async {
                    await UserService.updateSleepPreferences(sleepGoal: goal);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sleep goal set to $goal')),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showBedtimeDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              surface: AppColors.bgPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final bedtime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      await UserService.updateSleepPreferences(bedtimePreference: bedtime);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bedtime set to ${picked.format(context)}')),
        );
      }
    }
  }

  void _showExportDialog() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export coming soon')),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: const Text(
          'Clear Cache?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will clear temporary files and free up storage space.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await AccountSettingsService.clearAllSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Logout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await UserService.clearCurrentUser();
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => OnboardingScreen(
                    onComplete: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => NewHomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.accentError),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: AppColors.accentError),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentPrimary,
                  ),
                ),
              );

              // Delete account
              final success = await UserService.deleteAccount();

              if (mounted) {
                Navigator.pop(context); // Close loading dialog

                if (success) {
                  // Navigate to onboarding
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => OnboardingScreen(
                        onComplete: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => NewHomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to delete account. Please try again.',
                      ),
                      backgroundColor: AppColors.accentError,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.accentError),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'naazimsnh02@gmail.com',
      query: 'subject=Insomnia Butler Support',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email app')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  void _showGenerateDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Generate Data?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will generate 30 days of realistic sleep and journal data for your account. This is for testing only.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
              );

              try {
                final userId = await UserService.getCurrentUserId();
                if (userId != null) {
                  await client.dev.generateRealisticData(userId);
                  if (mounted) {
                    await _loadData(); // Reload data to update UI
                    Navigator.pop(context); // Close loading
                    widget.onDataChanged?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Realistic data generated successfully!')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accentError),
                  );
                }
              }
            },
            child: const Text('Generate', style: TextStyle(color: AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Clear All Data?', style: TextStyle(color: AppColors.accentError)),
        content: const Text(
          'This will permanently delete all your sleep sessions, journal entries, and chat history. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
              );

              try {
                final userId = await UserService.getCurrentUserId();
                if (userId != null) {
                  await client.dev.clearUserData(userId);
                  if (mounted) {
                    await _loadData(); // Reload data to update UI
                    Navigator.pop(context); // Close loading
                    widget.onDataChanged?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All data cleared successfully.')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accentError),
                  );
                }
              }
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.accentError)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Insomnia Butler',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Version $_appVersion',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Insomnia Butler is your personal sleep companion, designed to help you achieve better sleep through:',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildAboutFeature('🧠', 'AI-powered thought clearing'),
              _buildAboutFeature('📊', 'Sleep tracking and analytics'),
              _buildAboutFeature('📔', 'Sleep journal with insights'),
              _buildAboutFeature('🎯', 'Personalized sleep goals'),
              const SizedBox(height: 16),
              const Text(
                'Built with ❤️ to help you sleep better',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
