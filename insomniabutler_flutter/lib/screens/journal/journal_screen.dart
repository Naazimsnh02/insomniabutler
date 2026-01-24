import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import '../../utils/haptic_helper.dart';
import 'journal_editor_screen.dart';
import 'journal_detail_screen.dart';
import 'widgets/journal_skeleton.dart';

/// Journal Screen - Main hub for journaling
/// Features: Timeline, Calendar, Insights tabs with premium glassmorphic design
class JournalScreen extends StatefulWidget {
  final bool isTab;
  const JournalScreen({super.key, this.isTab = false});

  @override
  State<JournalScreen> createState() => JournalScreenState();
}

class JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _timelineScrollController;
  int _selectedTabIndex = 0;

  List<dynamic> _entries = [];
  List<dynamic> _calendarEntries = [];
  Map<String, dynamic>? _stats;
  List<dynamic> _insights = [];
  bool _isLoading = true;
  bool _isLoadingCalendar = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTabIndex = _tabController.index);
      if (_selectedTabIndex == 1 && _calendarEntries.isEmpty) {
        _loadCalendarData();
      }
    });
    _timelineScrollController = ScrollController();
    _timelineScrollController.addListener(_onScroll);
    _loadFromCache();
    loadData();
  }

  void _onScroll() {
    if (_timelineScrollController.position.pixels >=
            _timelineScrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore &&
        !_isLoading) {
      loadMoreEntries();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timelineScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('journal_stats');
      final insightsJson = prefs.getString('journal_insights');

      if (statsJson != null) {
        setState(() => _stats = jsonDecode(statsJson));
      }
      if (insightsJson != null) {
        setState(() => _insights = jsonDecode(insightsJson));
      }
    } catch (e) {
      debugPrint('Error loading journal cache: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_stats != null) {
        prefs.setString('journal_stats', jsonEncode(_stats));
      }
      if (_insights.isNotEmpty) {
        prefs.setString('journal_insights', jsonEncode(_insights));
      }
    } catch (e) {
      debugPrint('Error saving journal cache: $e');
    }
  }

  Future<void> _loadCalendarData() async {
    setState(() => _isLoadingCalendar = true);

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      final startOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final endOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59);

      final calendarEntries = await client.journal.getUserEntries(
        userId,
        limit: 100, // Sufficient for a month
        offset: 0,
        startDate: startOfMonth.toUtc(),
        endDate: endOfMonth.toUtc(),
      );

      setState(() {
        _calendarEntries = calendarEntries;
        _isLoadingCalendar = false;
      });
    } catch (e) {
      debugPrint('Error loading calendar data: $e');
      setState(() => _isLoadingCalendar = false);
    }
  }

  Future<void> loadData() async {
    if (_isLoading && _entries.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _hasMore = true;
    });

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      // Independent fetches so they don't block each other
      
      // 1. Fetch Entries
      client.journal.getUserEntries(userId, limit: _pageSize, offset: 0).then((entries) {
        if (mounted) {
          setState(() {
            _entries = entries;
            _currentOffset = entries.length;
            _hasMore = entries.length >= _pageSize;
            // If stats and insights are also not loading anymore, set _isLoading to false
            // but for now we rely on a combined state or separate ones.
            // Let's use separate loading states for more granules control if needed, 
            // but for Timeline, once entries are here, we are good.
            if (_selectedTabIndex == 0) _isLoading = false; 
          });
        }
      }).catchError((e) => debugPrint('Error loading entries: $e'));

      // 2. Fetch Stats
      client.journal.getJournalStats(userId).then((stats) {
        if (mounted) {
          setState(() {
            _stats = {
              'totalEntries': stats.totalEntries,
              'currentStreak': stats.currentStreak,
              'longestStreak': stats.longestStreak,
              'thisWeekEntries': stats.thisWeekEntries,
              'favoriteCount': stats.favoriteCount,
            };
          });
          _saveToCache();
        }
      }).catchError((e) => debugPrint('Error loading stats: $e'));

      // 3. Fetch Insights (Slowest call due to AI)
      client.journal.getJournalInsights(userId).then((insights) {
        if (mounted) {
          setState(() {
            _insights = insights;
            // If we are on Insights tab, stop global loading
            if (_selectedTabIndex == 2) _isLoading = false;
          });
          _saveToCache();
        }
      }).catchError((e) => debugPrint('Error loading insights: $e'));

      // Final fallback to stop loading indicator if all fail or after a timeout
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isLoading) setState(() => _isLoading = false);
      });

    } catch (e) {
      debugPrint('Error in loadData: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadMoreEntries() async {
    if (_isFetchingMore || !_hasMore) return;

    setState(() => _isFetchingMore = true);

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      final moreEntries = await client.journal.getUserEntries(
        userId,
        limit: _pageSize,
        offset: _currentOffset,
      );

      setState(() {
        _entries.addAll(moreEntries);
        _isFetchingMore = false;
        _currentOffset += moreEntries.length;
        _hasMore = moreEntries.length >= _pageSize;
      });
    } catch (e) {
      debugPrint('Error fetching more entries: $e');
      setState(() => _isFetchingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          top: 200,
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

        if (widget.isTab)
          Column(
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.sm),
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
          )
        else
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.sm),
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
            floatingActionButton: _buildFAB(),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.xl,
        AppSpacing.containerPadding,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sleep Journal',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),
              if (_stats != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accentPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_stats!['totalEntries']} moments shared',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          Row(
            children: [
              _buildIconButton(
                icon: Icons.search_rounded,
                onTap: () {
                  HapticHelper.lightImpact();
                  // TODO: Implement search
                },
              ),
              const SizedBox(width: 12),
              _buildIconButton(
                icon: Icons.refresh_rounded,
                onTap: () {
                  HapticHelper.lightImpact();
                  loadData();
                },
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontSize: 13,
        ),
        unselectedLabelStyle: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Timeline'),
          Tab(text: 'Calendar'),
          Tab(text: 'Insights'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTimelineTab() {
    if (_isLoading && _entries.isEmpty) {
      return const JournalSkeleton();
    }

    if (_entries.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadData,
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.bgSecondary,
      child: ListView.builder(
        controller: _timelineScrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerPadding,
          AppSpacing.md,
          AppSpacing.containerPadding,
          140, // Space for floating bottom tab bar
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: _entries.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _entries.length) {
            return _buildLoadMoreIndicator();
          }
          final entry = _entries[index];
          return _buildEntryCard(entry, index);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accentPrimary.withOpacity(0.5),
          ),
        ),
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
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        color: AppColors.bgSecondary.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (moodEmoji != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getMoodColor(mood).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(moodEmoji, style: const TextStyle(fontSize: 20)),
                      ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(date),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(date),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isFavorite)
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.accentError,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (title != null && title.isNotEmpty) ...[
              Text(
                title.trim().substring(0, 1).toUpperCase() +
                    title.trim().substring(1),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPrimary,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              content,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 12,
                  color: AppColors.textTertiary.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${content.split(' ').length} words',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Text(
                  'Read more',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentPrimary.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: AppColors.accentPrimary.withOpacity(0.7),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildCalendarTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.containerPadding,
        AppSpacing.containerPadding,
        140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateSelector(),
          const SizedBox(height: AppSpacing.lg),
          _buildCalendarGrid(),
          const SizedBox(height: AppSpacing.xl),
          if (_selectedDate != null) _buildSelectedDateEntries(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              HapticHelper.lightImpact();
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
              });
              _loadCalendarData();
            },
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              fontSize: 20,
            ),
          ),
          IconButton(
            onPressed: () {
              HapticHelper.lightImpact();
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
              });
              _loadCalendarData();
            },
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentPrimary.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          // Calendar days
          ...List.generate((daysInMonth + firstWeekday) ~/ 7 + 1, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
    final isToday =
        DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;
    final isSelected =
        _selectedDate != null &&
        _selectedDate!.year == date.year &&
        _selectedDate!.month == date.month &&
        _selectedDate!.day == date.day;

    // Find entries for this day using calendar-specific entries
    final dayEntries = _calendarEntries.where((entry) {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.accentPrimary.withOpacity(0.5))
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
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (hasEntries && !isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _getMoodColor(dominantMood),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getMoodColor(dominantMood).withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateEntries() {
    final selectedEntries = _calendarEntries.where((entry) {
      final entryDate = (entry.entryDate as DateTime).toLocal();
      return entryDate.year == _selectedDate!.year &&
          entryDate.month == _selectedDate!.month &&
          entryDate.day == _selectedDate!.day;
    }).toList();

    if (selectedEntries.isEmpty) {
      return GestureDetector(
        onTap: () async {
          await HapticHelper.mediumImpact();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JournalEditorScreen(initialDate: _selectedDate),
            ),
          );
          loadData();
          _loadCalendarData();
        },
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          color: AppColors.bgSecondary.withOpacity(0.3),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: AppColors.accentPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(_selectedDate!),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'No entry for this day',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Capture your thoughts',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPrimary.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Keep your streak alive and clear your mind before rest. Share how you\'re feeling today.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Share a moment',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppColors.accentPrimary,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            DateFormat('EEEE, MMMM d').format(_selectedDate!),
            style: AppTextStyles.label.copyWith(
              color: AppColors.accentAmber,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...selectedEntries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildEntryCard(entry, selectedEntries.indexOf(entry)),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  String? _getDominantMood(List<dynamic> entries) {
    if (entries.isEmpty) return null;
    final moods = entries
        .map((e) => e.mood as String?)
        .whereType<String>()
        .toList();
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
      'Great': const Color(0xFF66BB6A),
      'Good': const Color(0xFF9CCC65),
      'Okay': const Color(0xFFFFD54F),
      'Low': const Color(0xFFFFB74D),
      'Sad': const Color(0xFF64B5F6),
      'Anxious': const Color(0xFFBA68C8),
      'Frustrated': const Color(0xFFE57373),
      'Calm': const Color(0xFF4DD0E1),
      'Tired': const Color(0xFF90A4AE),
    };

    return moodColors[mood] ?? AppColors.accentPrimary;
  }

  Widget _buildInsightsTab() {
    if (_isLoading && _insights.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          children: [
            JournalSkeleton.statsSkeleton(),
            const SizedBox(height: 24),
            ...List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 80,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  color: AppColors.bgSecondary.withOpacity(0.2),
                  borderRadius: 20,
                  child: const SizedBox.shrink(),
                ),
              ),
            )),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: AppSpacing.xl),
          if (_insights.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'BUTLER INSIGHTS',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentPrimary,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ),
            ..._insights.map((insight) => _buildInsightCard(insight)),
            const SizedBox(height: 140),
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
                'Streak',
                AppColors.accentPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                '📝',
                '${_stats!['totalEntries']}',
                'Entries',
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
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return GlassCard(
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(dynamic insight) {
    final String message = (insight is Map) ? (insight['message'] ?? '') : (insight.message ?? '');
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo/butler_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.psychology_rounded, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUTLER ADVICE',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTextStyles.bodySm.copyWith(
                    height: 1.6,
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 64,
                color: AppColors.accentPrimary,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 2.seconds,
                ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your Journey Starts Here',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Journaling before bed helps clear your mind and improve sleep quality. Share your first moment with the Butler.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
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
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 2.seconds,
        );
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
