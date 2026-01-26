import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';
import 'manual_log_screen.dart';
import 'widgets/history_skeleton.dart';
import '../../services/health_data_service.dart';
import '../../services/sleep_sync_service.dart';
import '../health/sleep_data_import_screen.dart';

class SleepHistoryScreen extends StatefulWidget {
  const SleepHistoryScreen({super.key});

  @override
  State<SleepHistoryScreen> createState() => _SleepHistoryScreenState();
}

class _SleepHistoryScreenState extends State<SleepHistoryScreen> {
  List<SleepSession> _sessions = [];
  bool _isLoading = true;
  bool _hasChanged = false;
  
  // Health data
  final _healthService = HealthDataService();
  late final SleepSyncService _syncService;
  bool _healthConnected = false;
  String? _filterDataSource; // null = all, 'manual', 'healthkit', 'healthconnect'

  @override
  void initState() {
    super.initState();
    _syncService = SleepSyncService(_healthService, client);
    _checkHealthConnection();
    _loadFromCache();
    _loadHistory();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('sleep_sessions_history');
      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        final sessions = decoded.map((item) => SleepSession.fromJson(item)).toList();
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sleep cache: $e');
    }
  }

  Future<void> _loadHistory() async {
    if (_sessions.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final sessions = await client.sleepSession.getUserSessions(userId, 50);
      
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
        
        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = jsonEncode(sessions.map((s) => s.toJson()).toList());
        prefs.setString('sleep_sessions_history', jsonStr);
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkHealthConnection() async {
    try {
      final hasPermissions = await _healthService.hasPermissions();
      if (mounted) {
        setState(() => _healthConnected = hasPermissions);
      }
    } catch (e) {
      debugPrint('Error checking health connection: $e');
    }
  }

  List<SleepSession> get _filteredSessions {
    if (_filterDataSource == null) return _sessions;
    return _sessions.where((s) => s.sleepDataSource == _filterDataSource).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
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

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading && _sessions.isEmpty
                      ? const HistorySkeleton()
                      : _filteredSessions.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: AppColors.accentPrimary,
                          backgroundColor: AppColors.bgSecondary,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(
                              AppSpacing.containerPadding,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filteredSessions.length,
                            itemBuilder: (context, index) =>
                                _buildSessionCard(_filteredSessions[index], index),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          HapticHelper.mediumImpact();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManualLogScreen()),
          );
          if (result == true) {
            _hasChanged = true;
            _loadHistory();
          }
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
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
            onTap: () => Navigator.pop(context, _hasChanged),
          ),
          Column(
            children: [
              Text(
                'Sleep Journey',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'History of your rest',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (_healthConnected) ...[
                _buildIconButton(
                  icon: Icons.cloud_sync_rounded,
                  onTap: () async {
                    HapticHelper.lightImpact();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SleepDataImportScreen(
                          syncService: _syncService,
                        ),
                      ),
                    );
                    _loadHistory();
                  },
                ),
                const SizedBox(width: 8),
              ],
              _buildIconButton(
                icon: _filterDataSource == null 
                    ? Icons.filter_list_rounded 
                    : Icons.filter_list_off_rounded,
                onTap: _showFilterOptions,
              ),
            ],
          ),
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
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.nightlight_outlined,
              size: 48,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No sleep data logged',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your sleep sessions will appear here',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSessionCard(SleepSession session, int index) {
    final dateStr = DateFormat(
      'EEEE, MMM d',
    ).format(session.sessionDate.toLocal());

    final wakeTime = session.wakeTime ?? DateTime.now();
    final duration = wakeTime.difference(session.bedTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final quality = session.sleepQuality ?? 3;
    final qualityColor = _getQualityColor(quality);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        onTap: () async {
          HapticHelper.lightImpact();
          final editData = {
            'id': session.id,
            'sessionDate': session.sessionDate.toLocal(),
            'bedTime': session.bedTime.toLocal(),
            'wakeTime': wakeTime.toLocal(),
            'sleepQuality': quality,
            'deepSleepDuration': session.deepSleepDuration,
            'lightSleepDuration': session.lightSleepDuration,
            'remSleepDuration': session.remSleepDuration,
            'awakeDuration': session.awakeDuration,
            'hrv': session.hrv,
            'restingHeartRate': session.restingHeartRate,
            'respiratoryRate': session.respiratoryRate,
            'interruptions': session.interruptions,
          };

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManualLogScreen(initialData: editData),
            ),
          );
          if (result == true) {
            _hasChanged = true;
            _loadHistory();
          }
        },
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        color: AppColors.bgSecondary.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: qualityColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: qualityColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$quality',
                  style: AppTextStyles.h3.copyWith(
                    color: qualityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textTertiary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat.jm().format(session.bedTime.toLocal())} - ${DateFormat.jm().format(wakeTime.toLocal())}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (session.sleepDataSource != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          session.sleepDataSource == 'healthkit'
                              ? Icons.favorite
                              : session.sleepDataSource == 'healthconnect'
                                  ? Icons.health_and_safety
                                  : Icons.edit,
                          size: 10,
                          color: session.sleepDataSource == 'healthkit'
                              ? const Color(0xFFFF2D55)
                              : session.sleepDataSource == 'healthconnect'
                                  ? const Color(0xFF00D4AA)
                                  : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          session.sleepDataSource == 'healthkit'
                              ? 'HealthKit'
                              : session.sleepDataSource == 'healthconnect'
                                  ? 'Health Connect'
                                  : 'Manual',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            color: session.sleepDataSource == 'healthkit'
                                ? const Color(0xFFFF2D55)
                                : session.sleepDataSource == 'healthconnect'
                                    ? const Color(0xFF00D4AA)
                                    : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${hours}h ${minutes}m',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  Text(
                    'SLEEP',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 22,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  Color _getQualityColor(int quality) {
    if (quality >= 4) return AppColors.accentSuccess;
    if (quality >= 3) return AppColors.accentAmber;
    return AppColors.accentPrimary;
  }

  void _showFilterOptions() {
    HapticHelper.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Data Source',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('All Sessions', null, Icons.all_inclusive),
            _buildFilterOption('Manual Entries', 'manual', Icons.edit),
            _buildFilterOption('HealthKit', 'healthkit', Icons.favorite),
            _buildFilterOption('Health Connect', 'healthconnect', Icons.health_and_safety),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String? value, IconData icon) {
    final isSelected = _filterDataSource == value;
    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        setState(() => _filterDataSource = value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentPrimary.withOpacity(0.1) 
              : AppColors.bgPrimary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.accentPrimary 
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.accentPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
