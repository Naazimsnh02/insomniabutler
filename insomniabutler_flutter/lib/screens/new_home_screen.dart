import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import 'thought_clearing_screen.dart';
import '../main.dart';
import '../services/user_service.dart';
import '../utils/haptic_helper.dart';
import 'sleep_tracking/sleep_timer_screen.dart';
import 'sleep_tracking/manual_log_screen.dart';
import 'sleep_tracking/sleep_history_screen.dart';
import '../services/sleep_timer_service.dart';

/// Home Dashboard - Main app screen
/// Redesigned with premium high-fidelity UI inspired by modern sleep trackers
class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> with SingleTickerProviderStateMixin {
  final _timerService = SleepTimerService();
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
    
    // Listen to timer changes
    _timerService.onTick.listen((_) {
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
              lastDate.difference(session.sessionDate).inDays == 1) {
            streak++;
            lastDate = session.sessionDate;
          } else {
            break;
          }
        }
      }
      
      setState(() {
        if (insights.latencyImprovement > 0) _latencyImprovement = insights.latencyImprovement;
        if (insights.avgLatencyWithButler > 0) _avgSleep = (insights.avgLatencyWithButler / 60).clamp(0, 12);
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
        _affirmation = '"The morning breeze has secrets to tell you. Don\'t go back to sleep."';
      } else if (hour >= 12 && hour < 17) {
        _affirmation = '"Your energy is a precious resource. Use it wisely today."';
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
              surface: AppColors.backgroundDeep,
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
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgPrimary,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildTopBar(),
                _buildCalendarStrip(),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.lg),
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
            ),
          ),

          // Bottom UI Components
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavArea(),
          ),
        ],
      ),
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
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'Home',
                  style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticHelper.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SleepHistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.glassBgElevated,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    HapticHelper.lightImpact();
                    // TODO: Implement full calendar history
                  },
                  icon: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.glassBgElevated,
                    padding: const EdgeInsets.all(10),
                  ),
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
    final days = List.generate(7, (index) => now.subtract(Duration(days: 3 - index)));

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
            final isToday = date.day == now.day && date.month == now.month;

            return GestureDetector(
              onTap: () {
                HapticHelper.lightImpact();
                setState(() => _selectedDate = date);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentPrimary.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  border: isSelected ? Border.all(color: AppColors.accentPrimary.withOpacity(0.5)) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase()[0],
                      style: AppTextStyles.label.copyWith(
                        color: isSelected ? AppColors.accentPrimary : AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected ? AppColors.gradientPrimary : null,
                        border: isToday && !isSelected 
                            ? Border.all(color: AppColors.accentPrimary, width: 1.5) 
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: AppTextStyles.bodySm.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
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
      ).animate().fadeIn(),
    );
  }

  Widget _buildDailyAffirmation() {
    return GlassCard(
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
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accentAmber),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
           Text(
            _affirmation,
            style: AppTextStyles.bodyLg.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
              const SizedBox(width: 12),
              Icon(Icons.share_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildSleepGauge() {
    final dateStr = DateFormat('EEE, dd MMMM').format(_selectedDate);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateStr, style: AppTextStyles.h4),
            const Icon(Icons.ios_share_rounded, color: AppColors.textSecondary, size: 20),
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
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: Colors.white24),
                  Text(
                    'Sleep Score',
                    style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _calculateDuration(),
                    style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Sleep duration',
                    style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
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
                      math.cos(angle) * 1.15, // Move slightly OUTSIDE the ring for better clarity
                      math.sin(angle) * 1.15
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
             Column(
              children: [
                Text('Time in bed', style: AppTextStyles.caption),
                Text(
                  '${_bedtime.format(context)} - ${_alarm.format(context)}', 
                  style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold)
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              children: [
                Text('Sleep Quality', style: AppTextStyles.caption),
                Text(
                  _getQualityText(), 
                  style: AppTextStyles.bodySm.copyWith(
                    color: _getQualityColor(),
                    fontWeight: FontWeight.bold,
                  )
                ),
              ],
            ),
          ],
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
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
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
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

  Widget _buildTimeCard(String title, String time, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.glassBgElevated,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(color: AppColors.glassBorder),
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
                    const SizedBox(width: 4),
                    Text(title, style: AppTextStyles.caption),
                  ],
                ),
                const Icon(Icons.edit_outlined, size: 14, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
            final isSelected = _selectedMood == mood['label'];
            return GestureDetector(
              onTap: () {
                HapticHelper.lightImpact();
                setState(() => _selectedMood = mood['label']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mood logged: ${mood['label']} ${mood['emoji']}'),
                    backgroundColor: AppColors.accentPrimary.withOpacity(0.9),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentPrimary : AppColors.glassBgElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.accentPrimary : AppColors.glassBorder,
                  ),
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
    ).animate().fadeIn();
  }

  Widget _buildImpactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sleep Insights', style: AppTextStyles.labelLg),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Row(
            children: [
              _buildSimpleStat('⚡', '${_latencyImprovement}%', 'Faster Sleep', color: AppColors.accentPrimary),
              const VerticalDivider(color: AppColors.glassBorder, width: 40),
              _buildSimpleStat('🔥', '${_streakDays}d', 'Sleep Streak', color: AppColors.accentAmber),
              const VerticalDivider(color: AppColors.glassBorder, width: 40),
              _buildSimpleStat('💤', '${_avgSleep.toStringAsFixed(1)}h', 'Avg. Rest', color: AppColors.accentSkyBlue),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSimpleStat(String emoji, String value, String label, {Color? color}) {
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
            )
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
            AppColors.backgroundDeep.withOpacity(0),
            AppColors.backgroundDeep.withOpacity(0.9),
            AppColors.backgroundDeep,
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
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.glassBgElevated.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                    border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
                  ),
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
          ),
          // Floating Action Button
          Positioned(
            bottom: 40,
            child: GestureDetector(
              onTap: () {
                HapticHelper.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThoughtClearingScreen()),
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
                child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 28),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -4, duration: 1500.ms),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _buildActiveTimerCard() {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SleepTimerScreen()),
        );
      },
      gradient: LinearGradient(
        colors: AppColors.gradientSuccess.colors.map((c) => c.withAlpha(25)).toList(),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentSuccess.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                duration: 2.seconds,
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
              ),
              const Icon(Icons.nightlight_round, color: AppColors.accentSuccess),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sleep Tracking Active', style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold)),
                Text('Tap to view your silent timer', style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
        ],
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
      colors: [AppColors.accentPrimary, AppColors.accentAmber, AppColors.accentSkyBlue],
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xxl)),
        gradient: AppColors.bgSecondary,
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
            'Guided Chat',
            'Let Butler clear your thoughts for better sleep.',
            Icons.chat_bubble_rounded,
            AppColors.gradientPrimary,
            () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ThoughtClearingScreen()));
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildOption(
            context,
            'Silent Timer',
            'Start a quiet timer for sleep and wake up to Butler.',
            Icons.timer_outlined,
            AppColors.gradientCalm,
            () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTimerScreen()));
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildOption(
            context,
            'Manual Log',
            'Retroactively log sleep duration and quality.',
            Icons.edit_note_rounded,
            null,
            () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualLogScreen()));
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Gradient? gradient,
    VoidCallback onTap,
  ) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? AppColors.glassBgElevated : null,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
