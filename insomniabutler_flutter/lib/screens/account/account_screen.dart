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
import '../distraction/distraction_settings_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import '../../services/notification_service.dart';
import '../../services/health_data_service.dart';
import '../../services/sleep_sync_service.dart';
import '../health/health_connection_screen.dart';
import 'package:intl/intl.dart';

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
  String _sleepGoal = '8 hours';
  int _totalSessions = 0;
  int _totalJournalEntries = 0;
  int _currentStreak = 0;
  String _appVersion = '';

  // Settings state
  bool _bedtimeNotifications = true;
  bool _insightsNotifications = true;
  bool _journalNotifications = true;
  String _bedtimeTime = '22:30';
  String _insightsTime = '09:00';
  String _journalTime = '21:00';

  // Permission state
  // bool _isOverlayGranted = false; // Removed
  bool _isUsageStatsGranted = false;
  bool _isNotificationGranted = false;
  bool _isBatteryOptimDisabled = false;
  bool _isExactAlarmGranted = false;
  
  // Health data state
  bool _healthDataConnected = false;
  bool _healthAutoSync = false;
  DateTime? _lastHealthSync;
  final _healthService = HealthDataService();
  late final SleepSyncService _syncService;
  
  bool _isLoading = true;
  Map<String, dynamic>? _cachedStats;

  @override
  void initState() {
    super.initState();
    _syncService = SleepSyncService(_healthService, client);
    _loadFromCache();
    _loadData();
    _loadHealthStatus();
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
        AccountSettingsService.getBedtimeTime(),
        AccountSettingsService.getInsightsTime(),
        AccountSettingsService.getJournalTime(),
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
      final settings = results[2] as List<dynamic>;
      final stats = results[3] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _userName = user?.name ?? _userName;
          _userEmail = user?.email ?? '';
          _accountCreatedAt = user?.createdAt;
          _sleepGoal = user?.sleepGoal ?? '8 hours';
          
          if (user?.bedtimePreference != null) {
             final bp = user!.bedtimePreference!;
             _bedtimeTime = '${bp.hour.toString().padLeft(2, '0')}:${bp.minute.toString().padLeft(2, '0')}';
          } else {
             _bedtimeTime = settings[6];
          }

          _totalSessions = stats['totalSleepSessions'] ?? 0;
          _totalJournalEntries = stats['totalJournalEntries'] ?? 0;
          _currentStreak = stats['currentStreak'] ?? 0;
          _cachedStats = stats;

          _bedtimeNotifications = settings[0];
          _insightsNotifications = settings[1];
          _journalNotifications = settings[2];
          _insightsTime = settings[7];
          _journalTime = settings[8];
          
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
          _isLoading = false;
        });
        _checkPermissionsStatus();
        _saveToCache(stats);
        await _syncNotifications();
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

  Future<void> _checkPermissionsStatus() async {
    try {
      final notificationStatus = await Permission.notification.status;
      // final overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
      final usageGranted = await UsageStats.checkUsagePermission() ?? false;
      final batteryOptimDisabled = await Permission.ignoreBatteryOptimizations.status.isGranted;
      final exactAlarmGranted = await Permission.scheduleExactAlarm.status.isGranted;

      if (mounted) {
        setState(() {
          _isNotificationGranted = notificationStatus.isGranted;
          // _isOverlayGranted = overlayGranted;
          _isUsageStatsGranted = usageGranted;
          _isBatteryOptimDisabled = batteryOptimDisabled;
          _isExactAlarmGranted = exactAlarmGranted;
        });
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  Future<void> _loadHealthStatus() async {
    try {
      final hasPermissions = await _healthService.hasPermissions();
      final autoSyncEnabled = await _syncService.isAutoSyncEnabled();
      final lastSync = await _syncService.getLastSyncTime();

      if (mounted) {
        setState(() {
          _healthDataConnected = hasPermissions;
          _healthAutoSync = autoSyncEnabled;
          _lastHealthSync = lastSync;
        });
      }
    } catch (e) {
      debugPrint('Error loading health status: $e');
    }
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

                  _buildSectionHeader('Health Data'),
                  const SizedBox(height: AppSpacing.md),
                  _buildHealthDataSettings(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Notifications'),
                  const SizedBox(height: AppSpacing.md),
                  _buildNotificationSettings(),
                  const SizedBox(height: AppSpacing.xl),


                  _buildSectionHeader('System Permissions'),
                  const SizedBox(height: AppSpacing.md),
                  _buildPermissionsManager(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Data & Privacy'),
                  const SizedBox(height: AppSpacing.md),
                  _buildDataPrivacy(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader('Support & About'),
                  const SizedBox(height: AppSpacing.md),
                  _buildSupportAbout(),
                  const SizedBox(height: AppSpacing.xl),

                  // _buildSectionHeader('Developer Tools'),
                  // const SizedBox(height: AppSpacing.md),
                  // _buildDevTools(),
                  // const SizedBox(height: AppSpacing.xl),

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
      padding: const EdgeInsets.all(12),
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
            subtitle: 'Recommended for your age',
            iconColor: AppColors.accentPrimary,
            trailing: _buildValueBox(_sleepGoal, _showSleepGoalDialog, color: AppColors.accentPrimary),
            onTap: _showSleepGoalDialog,
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.alarm_rounded,
            title: 'Preferred Bedtime',
            subtitle: 'Ideal time to start winding down',
            iconColor: AppColors.accentLavender,
            trailing: _buildValueBox(_formatTime(_bedtimeTime), _showBedtimeDialog, color: AppColors.accentLavender),
            onTap: _showBedtimeDialog,
          ),
          _buildDivider(),
          _buildSettingRow(
            icon: Icons.block_rounded,
            title: 'Distraction Blocking',
            subtitle: 'Manage blocked apps during bedtime',
            iconColor: Colors.orangeAccent,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onTap: () {
              HapticHelper.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DistractionSettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDataSettings() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            icon: _healthDataConnected ? Icons.health_and_safety : Icons.health_and_safety_outlined,
            title: 'Health Data Connection',
            subtitle: _healthDataConnected 
                ? 'Connected to ${Theme.of(context).platform == TargetPlatform.iOS ? "HealthKit" : "Health Connect"}'
                : 'Connect to sync sleep data',
            iconColor: _healthDataConnected ? const Color(0xFF4CAF50) : AppColors.textTertiary,
            trailing: Icon(
              _healthDataConnected ? Icons.check_circle : Icons.chevron_right_rounded,
              color: _healthDataConnected ? const Color(0xFF4CAF50) : AppColors.textTertiary,
              size: 20,
            ),
            onTap: () async {
              HapticHelper.lightImpact();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthConnectionScreen(
                    healthService: _healthService,
                    syncService: _syncService,
                  ),
                ),
              );
              _loadHealthStatus();
            },
          ),
          if (_healthDataConnected) ...[
            _buildDivider(),
            _buildToggleRow(
              icon: Icons.sync_rounded,
              title: 'Auto-Sync',
              subtitle: 'Automatically sync sleep data on app launch',
              iconColor: const Color(0xFF2196F3),
              value: _healthAutoSync,
              onChanged: (value) async {
                await HapticHelper.lightImpact();
                await _syncService.setAutoSyncEnabled(value);
                setState(() => _healthAutoSync = value);
              },
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: Icons.history_rounded,
              title: 'Last Sync',
              subtitle: _lastHealthSync != null
                  ? DateFormat('MMM dd, yyyy HH:mm').format(_lastHealthSync!)
                  : 'Never synced',
              iconColor: const Color(0xFF9C27B0),
              trailing: const SizedBox.shrink(),
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: Icons.cloud_sync_rounded,
              title: 'Manual Sync',
              subtitle: 'Sync sleep data now',
              iconColor: const Color(0xFF00BCD4),
              trailing: const Icon(
                Icons.sync_rounded,
                color: AppColors.accentSkyBlue,
                size: 20,
              ),
              onTap: () async {
                HapticHelper.mediumImpact();
                await _performManualSync();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
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
            subtitle: 'Schedule a nightly wind-down nudge',
            iconColor: const Color(0xFF64B5F6),
            value: _bedtimeNotifications,
            trailingExtra: _bedtimeNotifications ? _buildValueBox(
              _formatTime(_bedtimeTime),
              () => _pickNotificationTime(
                initialTime: _bedtimeTime,
                onSet: (val) async {
                  await AccountSettingsService.setBedtimeTime(val);
                  _bedtimeTime = val;
                },
                onSync: _syncBedtimeNotification,
              ),
              color: const Color(0xFF64B5F6),
            ) : null,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setBedtimeNotifications(value);
              setState(() => _bedtimeNotifications = value);
              await _syncBedtimeNotification();
            },
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.insights_rounded,
            title: 'Sleep Insights',
            subtitle: 'Personalized analysis for your rest',
            iconColor: const Color(0xFF81C784),
            value: _insightsNotifications,
            trailingExtra: _insightsNotifications ? _buildValueBox(
              _formatTime(_insightsTime),
              () => _pickNotificationTime(
                initialTime: _insightsTime,
                onSet: (val) async {
                  await AccountSettingsService.setInsightsTime(val);
                  _insightsTime = val;
                },
                onSync: _syncInsightsNotification,
              ),
              color: const Color(0xFF81C784),
            ) : null,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setInsightsNotifications(value);
              setState(() => _insightsNotifications = value);
              await _syncInsightsNotification();
            },
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.auto_stories_rounded,
            title: 'Journal Prompts',
            subtitle: 'Daily prompts for clear-thinking',
            iconColor: const Color(0xFFFFD54F),
            value: _journalNotifications,
            trailingExtra: _journalNotifications ? _buildValueBox(
              _formatTime(_journalTime),
              () => _pickNotificationTime(
                initialTime: _journalTime,
                onSet: (val) async {
                  await AccountSettingsService.setJournalTime(val);
                  _journalTime = val;
                },
                onSync: _syncJournalNotification,
              ),
              color: const Color(0xFFFFD54F),
            ) : null,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setJournalNotifications(value);
              setState(() => _journalNotifications = value);
              await _syncJournalNotification();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacy() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
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
      padding: const EdgeInsets.all(12),
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
      padding: const EdgeInsets.all(12),
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

          _buildDivider(),
          _buildSettingRow(
            icon: Icons.notifications_active_outlined,
            title: 'Test Notification',
            subtitle: 'Send high-priority notification',
            iconColor: Colors.blueAccent,
            trailing: const Icon(
              Icons.send_rounded,
              color: Colors.blueAccent,
              size: 20,
            ),
            onTap: () async {
              await HapticHelper.lightImpact();
              debugPrint('AccountScreen: Testing notification...');
              
              await NotificationService.showNotification(
                id: 999,
                title: 'Time for Bed',
                body: 'This is a test notification from Insomnia Butler.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 16),
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: titleColor ?? AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildValueBox(String value, VoidCallback onTap, {Color? color}) {
    final themeColor = color ?? AppColors.accentPrimary;
    return InkWell(
      onTap: () {
        HapticHelper.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: themeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            color: themeColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
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
    Widget? trailingExtra,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container with soft glow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: iconColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 18),
          
          // Text Content & Inline Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                if (trailingExtra != null) ...[
                  const SizedBox(height: 14),
                  trailingExtra,
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Main Toggle
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.accentPrimary,
              activeTrackColor: AppColors.accentPrimary.withOpacity(0.3),
              inactiveThumbColor: AppColors.textTertiary,
              inactiveTrackColor: Colors.white.withOpacity(0.08),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
                    setState(() => _sleepGoal = goal);
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

  Future<void> _syncNotifications() async {
    await _syncBedtimeNotification();
    await _syncInsightsNotification();
    await _syncJournalNotification();
  }

  Future<void> _syncBedtimeNotification() async {
    const id = 100;
    if (_bedtimeNotifications) {
      final parts = _bedtimeTime.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      await NotificationService.scheduleDailyNotification(
        id: id,
        title: 'Time for Bed 🌙',
        body: 'Your Butler is ready to help you wind down for a great night\'s sleep.',
        time: time,
      );
    } else {
      await NotificationService.cancelNotification(id);
    }
  }

  Future<void> _syncInsightsNotification() async {
    const id = 101;
    if (_insightsNotifications) {
      final parts = _insightsTime.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      await NotificationService.scheduleDailyNotification(
        id: id,
        title: 'Sleep Insights Ready 📊',
        body: 'Your personalized sleep analysis for last night is ready for review.',
        time: time,
      );
    } else {
      await NotificationService.cancelNotification(id);
    }
  }

  Future<void> _syncJournalNotification() async {
    const id = 102;
    if (_journalNotifications) {
      final parts = _journalTime.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      await NotificationService.scheduleDailyNotification(
        id: id,
        title: 'Evening Journaling 📔',
        body: 'Take a moment to clear your mind before bed with a quick journal entry.',
        time: time,
      );
    } else {
      await NotificationService.cancelNotification(id);
    }
  }

  Future<void> _pickNotificationTime({
    required String initialTime,
    required Function(String) onSet,
    required Function() onSync,
  }) async {
    final parts = initialTime.split(':');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
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
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await onSet(formatted);
      await onSync();
      setState(() {});
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final h = hour % 12 == 0 ? 12 : hour % 12;
      final m = minute.toString().padLeft(2, '0');
      return '$h:$m $ampm';
    } catch (e) {
      return timeStr;
    }
  }

  void _showBedtimeDialog() async {
    final parts = _bedtimeTime.split(':');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
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
      
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await AccountSettingsService.setBedtimeTime(formatted);
      setState(() => _bedtimeTime = formatted);
      
      if (_bedtimeNotifications) {
        await _syncBedtimeNotification();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bedtime set to ${picked.format(context)}')),
        );
      }
    }
  }

  Future<void> _performManualSync() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Perform sync for last 7 days
      final result = await _syncService.syncLastNDays(7);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (result != null && result.success) {
        await _loadHealthStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Synced ${result.sessionsImported} sessions'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Sync failed: ${result?.errors.join(", ") ?? "Unknown error"}'),
              backgroundColor: AppColors.accentError,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.accentError,
          ),
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
        title: const Text('Generate Professional Demo Data?', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will generate 30 days of professional, realistic data including:',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text('• Sleep sessions with detailed metrics', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('• Professional journal entries', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('• AI chat conversations with embeddings', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('• Thought logs across diverse categories', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('• Sleep insights and analytics', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              SizedBox(height: 12),
              Text(
                'Perfect for hackathon demos and testing all features!',
                style: TextStyle(color: AppColors.accentPrimary, fontSize: 12, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 8),
              Text(
                'Note: This may take 1-2 minutes to generate embeddings.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final dialogContext = context;
              Navigator.pop(dialogContext);
              
              // Show loading with message
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.accentPrimary),
                      SizedBox(height: 16),
                      Text(
                        'Generating professional data...\nThis may take 1-2 minutes',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );

              try {
                final userId = await UserService.getCurrentUserId();
                if (userId != null) {
                  await client.dev.generateRealisticData(userId);
                  if (mounted) {
                    Navigator.of(context).pop(); // Close loading
                    await _loadData(); // Reload data to update UI
                    widget.onDataChanged?.call();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✨ Professional demo data generated successfully!'),
                          backgroundColor: AppColors.accentPrimary,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                }
              } catch (e) {
                debugPrint('Error generating data: $e');
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.accentError,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: const Text('Generate', style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.bold)),
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
              final dialogContext = context;
              Navigator.pop(dialogContext);
              
              // Show loading
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
              );

              try {
                final userId = await UserService.getCurrentUserId();
                if (userId != null) {
                  await client.dev.clearUserData(userId);
                  if (mounted) {
                    Navigator.of(context).pop(); // Close loading
                    await _loadData(); // Reload data to update UI
                    widget.onDataChanged?.call();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All data cleared successfully.')),
                      );
                    }
                  }
                }
              } catch (e) {
                debugPrint('Error clearing data: $e');
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.accentError,
                      duration: const Duration(seconds: 5),
                    ),
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

  Widget _buildPermissionsManager() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          _buildPermissionItem(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: 'Required for reminders & overlays',
            isEnabled: _isNotificationGranted,
            iconColor: Colors.blueAccent,
            onTap: () => _requestPermission(Permission.notification),
          ),
          _buildDivider(),
          // _buildPermissionItem(
          //   icon: Icons.layers_rounded,
          //   title: 'Display Over Nudge',
          //   subtitle: 'Required for distraction blocking',
          //   isEnabled: _isOverlayGranted,
          //   iconColor: Colors.orangeAccent,
          //   onTap: () => _requestPermission(null, type: 'overlay'),
          // ),
          // _buildDivider(),
          _buildPermissionItem(
            icon: Icons.bar_chart_rounded,
            title: 'Usage Stats',
            subtitle: 'Detects apps during bedtime',
            isEnabled: _isUsageStatsGranted,
            iconColor: Colors.greenAccent,
            onTap: () => _requestPermission(null, type: 'usage'),
          ),
          _buildPermissionItem(
            icon: Icons.alarm_on_rounded,
            title: 'Exact Alarms',
            subtitle: 'Ensures timely distraction checks',
            isEnabled: _isExactAlarmGranted,
            iconColor: Colors.purpleAccent,
            onTap: () => _requestPermission(Permission.scheduleExactAlarm, type: 'exact_alarm'),
          ),
          _buildDivider(),
          _buildPermissionItem(
            icon: Icons.battery_saver_rounded,
            title: 'Battery Optimization',
            subtitle: 'Keep butler running in background',
            isEnabled: _isBatteryOptimDisabled,
            iconColor: Colors.redAccent,
            onTap: () => _requestPermission(Permission.ignoreBatteryOptimizations),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return _buildSettingRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isEnabled 
            ? Colors.green.withOpacity(0.15) 
            : Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isEnabled ? Colors.green : Colors.orange).withOpacity(0.3),
          ),
        ),
        child: Text(
          isEnabled ? 'Granted' : 'Request',
          style: AppTextStyles.caption.copyWith(
            color: isEnabled ? Colors.greenAccent : Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _requestPermission(Permission? permission, {String? type}) async {
    await HapticHelper.mediumImpact();
    
    if (type == 'usage') {
      await UsageStats.grantUsagePermission();
    } else if (permission != null) {
      if (type == 'exact_alarm' && await permission.status.isGranted) {
        // If already granted, the user might want to check settings manually
        // Since we can't easily launch the specific Exact Alarm intent without a plugin,
        // we offer to open general app settings.
        _showSettingsDialog('Exact Alarms', 'This permission appears to serve "Granted".\n\nWould you like to open app settings to verify?');
      } else {
        final status = await permission.request();
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
      }
    }
    
    // Refresh status
    if (mounted) _checkPermissionsStatus();
  }

  void _showSettingsDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }
}
