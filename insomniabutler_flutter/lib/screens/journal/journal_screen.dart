import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import '../../utils/haptic_helper.dart';
import 'journal_editor_screen.dart';
import 'journal_detail_screen.dart';

/// Journal Screen - Main hub for journaling
/// Features: Timeline, Calendar, Insights tabs with glassmorphic design
class JournalScreen extends StatefulWidget {
  final bool isTab;
  const JournalScreen({Key? key, this.isTab = false}) : super(key: key);

  @override
  State<JournalScreen> createState() => JournalScreenState();
}

class JournalScreenState extends State<JournalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  List<dynamic> _entries = [];
  Map<String, dynamic>? _stats;
  List<dynamic> _insights = [];
  bool _isLoading = true;
  
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTabIndex = _tabController.index);
    });
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      // Load entries, stats, and insights
      final entries = await client.journal.getUserEntries(userId, limit: 50, offset: 0);
      final stats = await client.journal.getJournalStats(userId);
      final insights = await client.journal.getJournalInsights(userId);

      setState(() {
        _entries = entries;
        _stats = {
          'totalEntries': stats.totalEntries,
          'currentStreak': stats.currentStreak,
          'longestStreak': stats.longestStreak,
          'thisWeekEntries': stats.thisWeekEntries,
          'favoriteCount': stats.favoriteCount,
        };
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading journal data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTab) {
      return Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(),
                _buildCalendarTab(),
                _buildInsightsTab(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgPrimary,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTimelineTab(),
                    _buildCalendarTab(),
                    _buildInsightsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Journal',
                style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_stats != null)
                Text(
                  '${_stats!['totalEntries']} entries • ${_stats!['currentStreak']}🔥 streak',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticHelper.lightImpact();
                  // TODO: Implement search
                },
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.glassBgElevated,
                  padding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  HapticHelper.lightImpact();
                  loadData();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.glassBgElevated,
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTextStyles.labelLg.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: AppTextStyles.labelLg.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Timeline'),
          Tab(text: 'Calendar'),
          Tab(text: 'Insights'),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildTimelineTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentPrimary),
      );
    }

    if (_entries.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadData,
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.glassBgElevated,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return _buildEntryCard(entry, index);
        },
      ),
    );
  }

  Widget _buildEntryCard(dynamic entry, int index) {
    final mood = entry.mood as String?;
    final moodEmoji = _getMoodEmoji(mood);
    final date = (entry.entryDate as DateTime).toLocal();
    final title = entry.title as String?;
    final content = entry.content as String;
    final isFavorite = entry.isFavorite as bool;

    return GestureDetector(
      onTap: () async {
        await HapticHelper.lightImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JournalDetailScreen(entryId: entry.id!),
          ),
        );
        loadData(); // Refresh after returning
      },
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (moodEmoji != null) ...[
                      Text(moodEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, MMM d').format(date),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(date),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isFavorite)
                  const Icon(
                    Icons.favorite,
                    color: AppColors.accentError,
                    size: 16,
                  ),
              ],
            ),
            if (title != null && title.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              content,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate(key: ValueKey('entry_${entry.id}'))
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildCalendarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildCalendarGrid(),
          const SizedBox(height: AppSpacing.xl),
          if (_selectedDate != null) _buildSelectedDateEntries(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              HapticHelper.lightImpact();
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              HapticHelper.lightImpact();
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDayOfMonth.day;

    return GlassCard(
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          // Calendar days
          ...List.generate((daysInMonth + firstWeekday) ~/ 7 + 1, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 40, height: 40);
                  }
                  return _buildCalendarDay(dayNumber);
                }),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildCalendarDay(int day) {
    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    final isToday = DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;
    final isSelected = _selectedDate != null &&
        _selectedDate!.year == date.year &&
        _selectedDate!.month == date.month &&
        _selectedDate!.day == date.day;

    // Find entries for this day
    final dayEntries = _entries.where((entry) {
      final entryDate = (entry.entryDate as DateTime).toLocal();
      return entryDate.year == date.year &&
          entryDate.month == date.month &&
          entryDate.day == date.day;
    }).toList();

    final hasEntries = dayEntries.isNotEmpty;
    final dominantMood = hasEntries ? _getDominantMood(dayEntries) : null;

    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppColors.gradientPrimary
              : isToday
                  ? LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.3),
                        AppColors.accentPrimary.withOpacity(0.1),
                      ],
                    )
                  : null,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.accentPrimary, width: 1)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: AppTextStyles.bodySm.copyWith(
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? AppColors.accentPrimary
                        : AppColors.textPrimary,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasEntries && !isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getMoodColor(dominantMood),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateEntries() {
    final selectedEntries = _entries.where((entry) {
      final entryDate = (entry.entryDate as DateTime).toLocal();
      return entryDate.year == _selectedDate!.year &&
          entryDate.month == _selectedDate!.month &&
          entryDate.day == _selectedDate!.day;
    }).toList();

    if (selectedEntries.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            const Icon(Icons.event_note, color: AppColors.textTertiary, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No entries for ${DateFormat('MMM d, yyyy').format(_selectedDate!)}',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d').format(_selectedDate!),
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.accentAmber,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...selectedEntries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildEntryCard(entry, selectedEntries.indexOf(entry)),
            )),
      ],
    ).animate().fadeIn();
  }

  String? _getDominantMood(List<dynamic> entries) {
    if (entries.isEmpty) return null;
    final moods = entries.map((e) => e.mood as String?).whereType<String>().toList();
    if (moods.isEmpty) return null;
    
    final moodCounts = <String, int>{};
    for (var mood in moods) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    
    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Color _getMoodColor(String? mood) {
    if (mood == null) return AppColors.accentPrimary;
    
    final moodColors = {
      'Great': const Color(0xFF4CAF50),
      'Good': const Color(0xFF8BC34A),
      'Okay': const Color(0xFFFFC107),
      'Low': const Color(0xFFFF9800),
      'Sad': const Color(0xFF2196F3),
      'Anxious': const Color(0xFF9C27B0),
      'Frustrated': const Color(0xFFF44336),
      'Calm': const Color(0xFF00BCD4),
      'Tired': const Color(0xFF607D8B),
    };
    
    return moodColors[mood] ?? AppColors.accentPrimary;
  }

  Widget _buildInsightsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentPrimary),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: AppSpacing.xl),
          if (_insights.isNotEmpty) ...[
            Text('AI Insights', style: AppTextStyles.labelLg),
            const SizedBox(height: AppSpacing.md),
            ..._insights.map((insight) => _buildInsightCard(insight)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_stats == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '🔥',
                '${_stats!['currentStreak']}',
                'Day Streak',
                AppColors.accentPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                '📝',
                '${_stats!['totalEntries']}',
                'Total Entries',
                AppColors.accentSkyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '✨',
                '${_stats!['thisWeekEntries']}',
                'This Week',
                AppColors.accentAmber,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                '❤️',
                '${_stats!['favoriteCount']}',
                'Favorites',
                AppColors.accentError,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return GlassCard(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(dynamic insight) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      gradient: LinearGradient(
        colors: [
          AppColors.accentPrimary.withOpacity(0.1),
          AppColors.glassBgElevated.withOpacity(0.5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              insight.message as String,
              style: AppTextStyles.body.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              size: 80,
              color: AppColors.accentPrimary,
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2.seconds, color: Colors.white24),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Start Your Sleep Journal',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Journaling before bed helps clear your mind and improve sleep quality. Tap the + button to write your first entry.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () async {
        await HapticHelper.mediumImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JournalEditorScreen()),
        );
        loadData(); // Refresh after creating entry
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
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -4, duration: 1500.ms);
  }

  String? _getMoodEmoji(String? mood) {
    if (mood == null) return null;
    final moodMap = {
      'Great': '😊',
      'Good': '🙂',
      'Okay': '😐',
      'Low': '😔',
      'Sad': '😢',
      'Anxious': '😰',
      'Frustrated': '😡',
      'Calm': '😌',
      'Tired': '🥱',
    };
    return moodMap[mood];
  }
}
