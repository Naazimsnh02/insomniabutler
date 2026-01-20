import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../services/user_service.dart';
import '../../services/account_settings_service.dart';
import '../../utils/haptic_helper.dart';
import '../../main.dart';
import '../onboarding/onboarding_screen.dart';
import '../new_home_screen.dart';

/// Account & Settings Screen
/// Provides comprehensive account management, app settings, and user preferences
class AccountScreen extends StatefulWidget {
  final bool isTab;

  const AccountScreen({Key? key, this.isTab = true}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user data
      final user = await UserService.getCurrentUser();
      final userName = await UserService.getCachedUserName();
      
      // Load app settings
      final bedtimeNotif = await AccountSettingsService.getBedtimeNotifications();
      final insightsNotif = await AccountSettingsService.getInsightsNotifications();
      final journalNotif = await AccountSettingsService.getJournalNotifications();
      final haptics = await AccountSettingsService.getHapticsEnabled();
      final sounds = await AccountSettingsService.getSoundEffectsEnabled();
      final autoStart = await AccountSettingsService.getAutoStartTracking();
      
      // Load app version
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Load user stats (placeholder for now, will be implemented with backend)
      // TODO: Implement getUserStats endpoint
      
      setState(() {
        _userName = user?.name ?? userName;
        _userEmail = user?.email ?? '';
        _accountCreatedAt = user?.createdAt;
        _bedtimeNotifications = bedtimeNotif;
        _insightsNotifications = insightsNotif;
        _journalNotifications = journalNotif;
        _hapticsEnabled = haptics;
        _soundEffectsEnabled = sounds;
        _autoStartTracking = autoStart;
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading account data: $e');
      setState(() => _isLoading = false);
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentPrimary),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Profile Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                _buildProfileHeader(),
                const SizedBox(height: AppSpacing.lg),
                _buildStatsRow(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        
        // Settings Sections
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
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
              
              _buildLogoutButton(),
              const SizedBox(height: AppSpacing.xxl),
              const SizedBox(height: 100), // Bottom nav spacing
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return GlassCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientPrimary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(),
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Name
            Text(
              _userName,
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            
            // Email
            Text(
              _userEmail,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            
            // Account age
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentPrimary.withOpacity(0.3)),
              ),
              child: Text(
                'Member for ${_getAccountAge()}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('🌙', _totalSessions.toString(), 'Sleep Sessions')),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildStatCard('📔', _totalJournalEntries.toString(), 'Journal Entries')),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildStatCard('🔥', _currentStreak.toString(), 'Day Streak')),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return GlassCard(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accentPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLg.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSleepPreferences() {
    return GlassCard(
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.bedtime_rounded,
            title: 'Sleep Goal',
            subtitle: '8 hours per night',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () {
              HapticHelper.lightImpact();
              _showSleepGoalDialog();
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.alarm_rounded,
            title: 'Preferred Bedtime',
            subtitle: '11:00 PM',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
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
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.notifications_rounded,
            title: 'Bedtime Reminders',
            subtitle: 'Get reminded when it\'s time for bed',
            value: _bedtimeNotifications,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setBedtimeNotifications(value);
              setState(() => _bedtimeNotifications = value);
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildToggleRow(
            icon: Icons.insights_rounded,
            title: 'Sleep Insights',
            subtitle: 'Receive personalized sleep insights',
            value: _insightsNotifications,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setInsightsNotifications(value);
              setState(() => _insightsNotifications = value);
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildToggleRow(
            icon: Icons.auto_stories_rounded,
            title: 'Journal Prompts',
            subtitle: 'Daily journal writing reminders',
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
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Feel vibrations when interacting',
            value: _hapticsEnabled,
            onChanged: (value) async {
              if (value) await HapticHelper.lightImpact();
              await AccountSettingsService.setHapticsEnabled(value);
              setState(() => _hapticsEnabled = value);
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildToggleRow(
            icon: Icons.volume_up_rounded,
            title: 'Sound Effects',
            subtitle: 'Play sounds for interactions',
            value: _soundEffectsEnabled,
            onChanged: (value) async {
              await HapticHelper.lightImpact();
              await AccountSettingsService.setSoundEffectsEnabled(value);
              setState(() => _soundEffectsEnabled = value);
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildToggleRow(
            icon: Icons.auto_awesome_rounded,
            title: 'Auto-Start Tracking',
            subtitle: 'Automatically track sleep at bedtime',
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
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.download_rounded,
            title: 'Export Sleep Data',
            subtitle: 'Download your data as CSV',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () {
              HapticHelper.lightImpact();
              _showExportDialog();
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () {
              HapticHelper.lightImpact();
              _showClearCacheDialog();
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.textTertiary, size: 18),
            onTap: () {
              HapticHelper.lightImpact();
              // TODO: Open privacy policy URL
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.accentError),
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
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: _appVersion,
            trailing: const SizedBox.shrink(),
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.help_outline_rounded,
            title: 'Help & FAQ',
            subtitle: 'Get answers to common questions',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () {
              HapticHelper.lightImpact();
              // TODO: Navigate to help screen
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle: 'Get help from our team',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () {
              HapticHelper.lightImpact();
              // TODO: Open email or support form
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.star_outline_rounded,
            title: 'Rate Insomnia Butler',
            subtitle: 'Share your feedback',
            trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.textTertiary, size: 18),
            onTap: () {
              HapticHelper.lightImpact();
              // TODO: Open app store rating
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildSettingRow(
            icon: Icons.share_rounded,
            title: 'Share with Friends',
            subtitle: 'Help others sleep better',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () {
              HapticHelper.lightImpact();
              // TODO: Open share dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.glassBgElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: titleColor ?? AppColors.accentPrimary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.glassBgElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accentPrimary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentPrimary,
            activeTrackColor: AppColors.accentPrimary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GlassCard(
      onTap: () {
        HapticHelper.mediumImpact();
        _showLogoutDialog();
      },
      gradient: LinearGradient(
        colors: [
          AppColors.accentError.withOpacity(0.1),
          AppColors.accentError.withOpacity(0.05),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, color: AppColors.accentError),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Logout',
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.accentError,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showSleepGoalDialog() {
    // TODO: Implement sleep goal selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep goal setting coming soon')),
    );
  }

  void _showBedtimeDialog() {
    // TODO: Implement bedtime selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bedtime setting coming soon')),
    );
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
        backgroundColor: AppColors.backgroundDeep,
        title: const Text('Clear Cache?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear temporary files and free up storage space.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await AccountSettingsService.clearAllSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDeep,
        title: const Text('Logout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await UserService.clearCurrentUser();
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => OnboardingScreen(
                  onComplete: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => NewHomeScreen()),
                      (route) => false,
                    );
                  },
                )),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.accentError)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDeep,
        title: const Text('Delete Account?', style: TextStyle(color: AppColors.accentError)),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion coming soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.accentError)),
          ),
        ],
      ),
    );
  }
}
