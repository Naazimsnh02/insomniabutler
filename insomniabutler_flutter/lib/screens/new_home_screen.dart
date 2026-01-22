import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import 'insomnia_butler_screen.dart';
import '../main.dart';
import '../services/user_service.dart';
import '../utils/haptic_helper.dart';
import 'sleep_tracking/sleep_timer_screen.dart';
import 'sleep_tracking/manual_log_screen.dart';
import 'sleep_tracking/sleep_history_screen.dart';
import '../services/sleep_timer_service.dart';
import 'journal/journal_screen.dart';
import 'journal/journal_editor_screen.dart';
import 'account/account_screen.dart';

/// Home Dashboard - Main app screen
/// Redesigned with premium high-fidelity UI inspired by modern sleep trackers
class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with SingleTickerProviderStateMixin {
  final _timerService = SleepTimerService();
  final GlobalKey<JournalScreenState> _journalKey = GlobalKey();
  int _selectedNavIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;

  // User data
  String _userName = 'User';
  int? _userId;

  // Insights data - Initialized with premium demo values
  int _latencyImprovement = 82;
  double _avgSleep = 7.5;
  int _streakDays = 5;
  bool _isLoadingInsights = true;

  // Last night's sleep data
  Duration? _lastNightDuration;
  int? _lastNightQuality;
  int _lastNightInterruptions = 0;
  double? _sleepEfficiency;
  bool _hasLastNightData = false;

  // Advanced Sleep Data
  int? _deepMinutes;
  int? _lightMinutes;
  int? _remMinutes;
  int? _awakeMinutes;
  int? _rhr;
  int? _hrv;

  // Real data state
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _alarm = const TimeOfDay(hour: 7, minute: 0);
  String _affirmation = '"Everything meant for you is on the good way"';

  final List<Map<String, String>> _moods = [
    {'emoji': '😠', 'label': 'Angry'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😑', 'label': 'Blah'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '➕', 'label': 'Add'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadInsights();

    // Listen to timer ticks and status changes
    _timerService.onTick.listen((_) {
      if (mounted) setState(() {});
    });
    _timerService.onStatusChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await UserService.getCurrentUserId();
      final userName = await UserService.getCachedUserName();

      setState(() {
        _userId = userId;
        _userName = userName;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadInsights() async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) {
        setState(() => _isLoadingInsights = false);
        return;
      }

      final insights = await client.insights.getUserInsights(userId);

      // Calculate streak (simplified)
      final sessions = await client.insights.getSleepTrend(userId, 30);
      int streak = 0;
      DateTime? lastDate;

      for (var session in sessions.reversed) {
        if (session.usedButler) {
          if (lastDate == null ||
              lastDate.difference(session.sessionDate.toLocal()).inDays == 1) {
            streak++;
            lastDate = session.sessionDate.toLocal();
          } else {
            break;
          }
        }
      }

      // Get last night's session
      final lastNight = await client.sleepSession.getLastNightSession(userId);
      if (lastNight != null && lastNight.wakeTime != null) {
        final duration = lastNight.wakeTime!.difference(lastNight.bedTime);
        final timeInBed = duration;

        // Calculate sleep efficiency (assuming minimal interruptions for now)
        // In a real app, this would come from accelerometer data
        final efficiency = (duration.inMinutes / timeInBed.inMinutes * 100)
            .clamp(0, 100);

        setState(() {
          _lastNightDuration = duration;
          _lastNightQuality = lastNight.sleepQuality;
          _sleepEfficiency = efficiency.toDouble();
          _hasLastNightData = true;
          // Estimate interruptions based on efficiency (demo logic)
          _lastNightInterruptions = efficiency > 90
              ? 0
              : efficiency > 80
              ? 1
              : 2;

          // Populate advanced metrics
          _deepMinutes = lastNight.deepSleepDuration;
          _lightMinutes = lastNight.lightSleepDuration;
          _remMinutes = lastNight.remSleepDuration;
          _awakeMinutes = lastNight.awakeDuration;
          _rhr = lastNight.restingHeartRate;
          _hrv = lastNight.hrv;
        });
      }

      setState(() {
        if (insights.latencyImprovement > 0)
          _latencyImprovement = insights.latencyImprovement;
        if (insights.avgLatencyWithButler > 0)
          _avgSleep = (insights.avgLatencyWithButler / 60)
              .clamp(0, 12)
              .toDouble();
        if (streak > 0) _streakDays = streak;
        _isLoadingInsights = false;
      });

      // Update affirmation based on time of day (mock real functionality)
      _updateAffirmationForTime();
    } catch (e) {
      debugPrint('Error loading insights: $e');
      setState(() => _isLoadingInsights = false);
      // Keep demo data on error
    }
  }

  void _updateAffirmationForTime() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour >= 5 && hour < 12) {
        _affirmation =
            '"The morning breeze has secrets to tell you. Don\'t go back to sleep."';
      } else if (hour >= 12 && hour < 17) {
        _affirmation =
            '"Your energy is a precious resource. Use it wisely today."';
      } else if (hour >= 17 && hour < 21) {
        _affirmation = '"As the sun sets, let go of any worries from the day."';
      } else {
        _affirmation = '"Everything meant for you is on the good way"';
      }
    });
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _alarm,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              onSurface: AppColors.textPrimary,
              surface: AppColors.bgPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      HapticHelper.mediumImpact();
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _alarm = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getQualityText() {
    if (_latencyImprovement >= 80) return 'Excellent!';
    if (_latencyImprovement >= 60) return 'Very Good';
    if (_latencyImprovement >= 40) return 'Good';
    return 'Improving';
  }

  Color _getQualityColor() {
    if (_latencyImprovement >= 80) return AppColors.accentSuccess;
    if (_latencyImprovement >= 60) return AppColors.accentSkyBlue;
    if (_latencyImprovement >= 40) return AppColors.accentAmber;
    return AppColors.accentPrimary;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _calculateDuration() {
    int bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    int alarmMinutes = _alarm.hour * 60 + _alarm.minute;

    int diff;
    if (alarmMinutes >= bedMinutes) {
      diff = alarmMinutes - bedMinutes;
    } else {
      diff = (24 * 60 - bedMinutes) + alarmMinutes;
    }

    int hours = diff ~/ 60;
    int minutes = diff % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgMainGradient,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: _buildBody(),
          ),

          // Bottom UI Components
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavArea(),
          ),

          // Journal Add Button (Floating above nav)
          if (_selectedNavIndex == 2)
            Positioned(
              right: 20,
              bottom: 120,
              child: _buildJournalFAB(),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomeTab();
      case 2:
        return JournalScreen(isTab: true, key: _journalKey);
      case 3:
        return const AccountScreen(isTab: true);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Sounds coming soon',
                style: AppTextStyles.h3.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildTopBar(),
        _buildCalendarStrip(),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.lg),
              if (_hasLastNightData) ...[
                _buildLastNightSummary(),
                const SizedBox(height: AppSpacing.xl),
                if (_deepMinutes != null || _rhr != null) ...[
                  _buildAdvancedMetrics(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
              _buildDailyAffirmation(),
              const SizedBox(height: AppSpacing.xl),
              _buildSleepGauge(),
              const SizedBox(height: AppSpacing.xl),
              _buildControlPanel(),
              const SizedBox(height: AppSpacing.xl),
              _buildStartTrackingButton(),
              const SizedBox(height: AppSpacing.xl),
              if (_timerService.isRunning) ...[
                _buildActiveTimerCard(),
                const SizedBox(height: AppSpacing.xl),
              ],
              _buildMoodTracker(),
              const SizedBox(height: AppSpacing.xl),
              _buildImpactSection(),
              const SizedBox(height: 140), // Space for fab & nav
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Home',
                  style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                _buildIconButton(
                  icon: Icons.history_rounded,
                  onTap: () {
                    HapticHelper.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SleepHistoryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildIconButton(
                  icon: Icons.calendar_today_rounded,
                  onTap: () {
                    HapticHelper.lightImpact();
                    // TODO: Implement full calendar history
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final now = DateTime.now();
    final days = List.generate(
      7,
      (index) => now.subtract(Duration(days: 3 - index)),
    );

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final isSelected =
                date.day == _selectedDate.day &&
                date.month == _selectedDate.month;
            final isToday = date.day == now.day && date.month == now.month;

            return GestureDetector(
              onTap: () {
                HapticHelper.lightImpact();
                setState(() => _selectedDate = date);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.15)
                      : AppColors.bgSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 1.5 : 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase()[0],
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected ? AppColors.gradientPrimary : null,
                        border: isToday && !isSelected
                            ? Border.all(
                                color: AppColors.accentPrimary.withOpacity(0.5),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: AppTextStyles.bodySm.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDailyAffirmation() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Affirmation',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.accentAmber,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.accentAmber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _affirmation,
            style: AppTextStyles.bodyLg.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.textPrimary.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMicroAction(Icons.favorite_outline_rounded),
              const SizedBox(width: 24),
              _buildMicroAction(Icons.share_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastNightSummary() {
    if (_lastNightDuration == null) return const SizedBox.shrink();

    final hours = _lastNightDuration!.inHours;
    final minutes = _lastNightDuration!.inMinutes.remainder(60);
    final quality = _lastNightQuality ?? 3;

    // Quality-based colors
    Color qualityColor = AppColors.accentPrimary;
    String qualityText = 'Good';
    if (quality >= 4) {
      qualityColor = AppColors.accentSuccess;
      qualityText = 'Excellent';
    } else if (quality <= 2) {
      qualityColor = AppColors.accentError;
      qualityText = 'Poor';
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Night',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${hours}h ${minutes}m',
                            style: AppTextStyles.h2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: qualityColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: qualityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: qualityColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              qualityText,
                              style: AppTextStyles.caption.copyWith(
                                color: qualityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      qualityColor.withOpacity(0.3),
                      qualityColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: qualityColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.bedtime_rounded,
                  color: qualityColor,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.star_rounded,
                  value: '$quality/5',
                  label: 'Quality',
                  color: qualityColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassBorder,
              ),
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.notifications_off_rounded,
                  value: '$_lastNightInterruptions',
                  label: 'Interruptions',
                  color: _lastNightInterruptions == 0
                      ? AppColors.accentSuccess
                      : AppColors.accentAmber,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassBorder,
              ),
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.trending_up_rounded,
                  value: '${_sleepEfficiency?.toStringAsFixed(0) ?? '--'}%',
                  label: 'Efficiency',
                  color: AppColors.accentSkyBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedMetrics() {
    return Column(
      children: [
        if (_deepMinutes != null) _buildSleepStructure(),
        if (_deepMinutes != null && _rhr != null)
          const SizedBox(height: AppSpacing.lg),
        if (_rhr != null || _hrv != null) _buildRecoveryCards(),
      ],
    );
  }

  Widget _buildSleepStructure() {
    final total =
        (_deepMinutes ?? 0) +
        (_lightMinutes ?? 0) +
        (_remMinutes ?? 0) +
        (_awakeMinutes ?? 0);
    if (total == 0) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Structure',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  _buildStructureBar(
                    _deepMinutes ?? 0,
                    total,
                    AppColors.accentPrimary,
                    'Deep',
                  ),
                  _buildStructureBar(
                    _remMinutes ?? 0,
                    total,
                    AppColors.accentSkyBlue,
                    'REM',
                  ),
                  _buildStructureBar(
                    _lightMinutes ?? 0,
                    total,
                    AppColors.textSecondary,
                    'Light',
                  ),
                  _buildStructureBar(
                    _awakeMinutes ?? 0,
                    total,
                    AppColors.accentAmber,
                    'Awake',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                'Deep',
                AppColors.accentPrimary,
                '${_deepMinutes}m',
              ),
              _buildLegendItem(
                'REM',
                AppColors.accentSkyBlue,
                '${_remMinutes}m',
              ),
              _buildLegendItem(
                'Light',
                AppColors.textSecondary,
                '${_lightMinutes}m',
              ),
              _buildLegendItem(
                'Awake',
                AppColors.accentAmber,
                '${_awakeMinutes}m',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStructureBar(int value, int total, Color color, String label) {
    if (value <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: value,
      child: Container(color: color),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecoveryCards() {
    return Row(
      children: [
        if (_rhr != null)
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.bgSecondary.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.accentError,
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_rhr bpm',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Resting HR',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_rhr != null && _hrv != null) const SizedBox(width: 12),
        if (_hrv != null)
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.bgSecondary.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.monitor_heart_rounded,
                    color: AppColors.accentSuccess,
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_hrv ms',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'HRV',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSleepGauge() {
    final dateStr = DateFormat('EEE, dd MMMM').format(_selectedDate);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateStr, style: AppTextStyles.h4),
            const Icon(
              Icons.ios_share_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withOpacity(0.1),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Gauge Arc Placeholder (Using a decorated container for now)
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 2),
                ),
                child: CustomPaint(
                  painter: _GaugePainter(_latencyImprovement.toDouble() / 100),
                ),
              ),
              // Inner Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                        '${_latencyImprovement.clamp(0, 100)}%',
                        style: AppTextStyles.displayMd.copyWith(
                          color: AppColors.accentPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(duration: 3.seconds, color: Colors.white24),
                  Text(
                    'Sleep Score',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _calculateDuration(),
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sleep duration',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Time Labels on Circle
              ...List.generate(4, (i) {
                final double angle = (i * 90 - 90) * (math.pi / 180);
                final time = ['12', '3', '6', '9'][i];
                // Using Alignment based on cos/sin for perfect circular placement
                return Positioned.fill(
                  child: Align(
                    alignment: Alignment(
                      math.cos(angle) *
                          1.15, // Move slightly OUTSIDE the ring for better clarity
                      math.sin(angle) * 1.15,
                    ),
                    child: Text(
                      time,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary.withOpacity(0.8),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMetricItem(
              'Time in bed',
              '${_bedtime.format(context)} - ${_alarm.format(context)}',
            ),
            const SizedBox(width: 32),
            _buildMetricItem(
              'Sleep Quality',
              _getQualityText(),
              color: _getQualityColor(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeCard(
            'Bedtime',
            _bedtime.format(context),
            Icons.bedtime_rounded,
            onTap: () => _selectTime(context, true),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildTimeCard(
            'Alarm',
            _alarm.format(context),
            Icons.alarm_rounded,
            onTap: () => _selectTime(context, false),
          ),
        ),
      ],
    );
  }

  Widget _buildStartTrackingButton() {
    return PrimaryButton(
      text: 'Start Tracking',
      onPressed: () => _showTrackingSelector(),
      icon: Icons.play_arrow_rounded,
    );
  }

  void _showTrackingSelector() {
    HapticHelper.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TrackingSelectorSheet(),
    );
  }

  Widget _buildTimeCard(
    String title,
    String time,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.accentPrimary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.edit_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How do you feel now?', style: AppTextStyles.labelLg),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _moods.map((mood) {
            final isAddedMood = mood['label'] == 'Add';
            final isSelected = _selectedMood == mood['label'];
            return GestureDetector(
              onTap: () async {
                HapticHelper.lightImpact();
                if (isAddedMood) {
                  // In professional apps, this would open a custom mood selector or note screen
                  return;
                }

                setState(() => _selectedMood = mood['label']);

                // Save to backend
                try {
                  final userId = await UserService.getCurrentUserId();
                  if (userId != null) {
                    await client.sleepSession.updateMoodForLatestSession(
                      userId,
                      mood['label']!,
                    );
                  }
                } catch (e) {
                  debugPrint('Error saving mood: $e');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.3)
                      : AppColors.bgSecondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary.withOpacity(0.6)
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentPrimary.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  mood['emoji']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImpactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          color: Colors.white.withOpacity(0.08),
          border: null,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sleep Insights',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.accentSkyBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Icon(
                    Icons.insights_rounded,
                    size: 16,
                    color: AppColors.accentSkyBlue,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSimpleStat(
                    '⚡',
                    '${_latencyImprovement}%',
                    'Faster Sleep',
                    color: AppColors.accentPrimary,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withOpacity(0.08),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  if (_sleepEfficiency != null) ...[
                    _buildSimpleStat(
                      '✨',
                      '${_sleepEfficiency!.toStringAsFixed(0)}%',
                      'Efficiency',
                      color: AppColors.accentSuccess,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.white.withOpacity(0.08),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ],
                  _buildSimpleStat(
                    '🔥',
                    '${_streakDays}d',
                    'Streak',
                    color: AppColors.accentAmber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(
    String emoji,
    String value,
    String label, {
    Color? color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLg.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildBottomNavArea() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimary.withOpacity(0),
            AppColors.bgPrimary.withOpacity(0.9),
            AppColors.bgPrimary,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nav Bar
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 24,
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 32,
              color: AppColors.bgSecondary.withOpacity(0.6),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              child: SizedBox(
                height: 72,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.nightlight_round, 'Home', 0),
                    _buildNavItem(Icons.music_note_rounded, 'Sounds', 1),
                    const SizedBox(width: 48), // Space for Mid FAB
                    _buildNavItem(Icons.auto_stories_rounded, 'Journal', 2),
                    _buildNavItem(Icons.person_outline_rounded, 'Account', 3),
                  ],
                ),
              ),
            ),
          ),
          // Floating Action Button (Thought Clearing)
          Positioned(
                bottom: 30,
                child: GestureDetector(
                  onTap: () {
                    HapticHelper.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InsomniaButlerScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
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
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo/butler_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.chat_bubble_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                      ),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -4, duration: 1500.ms),
        ],
      ),
    );
  }

  Widget _buildJournalFAB() {
    return GestureDetector(
      onTap: () async {
        await HapticHelper.mediumImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JournalEditorScreen()),
        );
        _journalKey.currentState?.loadData();
      },
      child:
          Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientCalm,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentSkyBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedNavIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticHelper.lightImpact();
          setState(() => _selectedNavIndex = index);
        },
        child: Container(
          height: double.infinity,
          color: Colors.transparent, // Ensures hit test works on empty space
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppColors.textTertiary,
                size: isActive ? 24 : 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? Colors.white : AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTimerCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      color: AppColors.accentSuccess.withOpacity(0.05),
      border: Border.all(
        color: AppColors.accentSuccess.withOpacity(0.2),
        width: 1.5,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SleepTimerScreen()),
        );
      },
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentSuccess.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  ),
              const Icon(
                Icons.nightlight_round,
                color: AppColors.accentSuccess,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sleep Tracking Active',
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentSuccess,
                  ),
                ),
                Text(
                  'Tap to view your silent timer',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentSuccess.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.accentSuccess,
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
        padding: const EdgeInsets.all(10),
        borderRadius: 12,
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMicroAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score; // 0.0 to 1.0

  _GaugePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2 - 2.5,
      5.0,
      false,
      trackPaint,
    );

    // Active Progress
    final progressGradient = const SweepGradient(
      colors: [
        AppColors.accentPrimary,
        AppColors.accentAmber,
        AppColors.accentSkyBlue,
      ],
      stops: [0.0, 0.4, 0.8],
      transform: GradientRotation(-3.14159 / 2 - 2.5),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final progressPaint = Paint()
      ..shader = progressGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2 - 2.5,
      score * 5.0, // Score mapped to arc (max sweep is approx 5.0 rad)
      false,
      progressPaint,
    );

    // Thumb Glow
    final thumbPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Position thumb at end of progress (trigonometry simplified)
    // For demo, just skip or draw a simple dot
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrackingSelectorSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgSecondary.withOpacity(0.8),
              AppColors.bgPrimary,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('How would you like to track?', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            _buildOption(
              context,
              'Insomnia Butler',
              'Let Butler clear your thoughts for better sleep.',
              assetPath: 'assets/logo/butler_logo.png',
              AppColors.gradientPrimary,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InsomniaButlerScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildOption(
              context,
              'Silent Timer',
              'Start a quiet timer for sleep and wake up to Butler.',
              AppColors.gradientCalm,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SleepTimerScreen()),
                );
              },
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildOption(
              context,
              'Manual Log',
              'Retroactively log sleep duration and quality.',
              AppColors.gradientLavender,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManualLogScreen()),
                );
              },
              icon: Icons.history_edu_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    String title,
    String subtitle,
    Gradient? gradient,
    VoidCallback onTap, {
    IconData? icon,
    String? assetPath,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: assetPath != null
                ? EdgeInsets.zero
                : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null
                  ? AppColors.bgSecondary.withOpacity(0.4)
                  : null,
              shape: BoxShape.circle,
              boxShadow: gradient != null
                  ? [
                      BoxShadow(
                        color: (gradient.colors.first).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: assetPath != null
                ? ClipOval(
                    child: Image.asset(
                      assetPath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          icon ?? Icons.error_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
