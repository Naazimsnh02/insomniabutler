import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';
import 'manual_log_screen.dart';

class SleepHistoryScreen extends StatefulWidget {
  const SleepHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SleepHistoryScreen> createState() => _SleepHistoryScreenState();
}

class _SleepHistoryScreenState extends State<SleepHistoryScreen> {
  List<SleepSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final sessions = await client.sleepSession.getUserSessions(userId, 50);
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentPrimary,
                        ),
                      )
                    : _sessions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: AppColors.accentPrimary,
                        backgroundColor: AppColors.bgPrimary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                            AppSpacing.containerPadding,
                          ),
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) =>
                              _buildSessionCard(_sessions[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManualLogScreen()),
          );
          if (result == true) _loadHistory();
        },
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Text(
            'Sleep History',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          _buildIconButton(
            icon: Icons.refresh_rounded,
            onTap: _loadHistory,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.nightlight_outlined,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No sessions logged yet',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SleepSession session) {
    final dateStr = DateFormat(
      'EEE, MMM d',
    ).format(session.sessionDate.toLocal());

    // Safety checks for wakeTime
    final wakeTime = session.wakeTime ?? DateTime.now();
    final duration = wakeTime.difference(session.bedTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final quality = session.sleepQuality ?? 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onTap: () async {
          HapticHelper.lightImpact();
          // Prepare data for editing
          final editData = {
            'id': session.id,
            'sessionDate': session.sessionDate.toLocal(),
            'bedTime': session.bedTime.toLocal(),
            'wakeTime': wakeTime.toLocal(),
            'sleepQuality': quality,
          };

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManualLogScreen(initialData: editData),
            ),
          );
          if (result == true) _loadHistory();
        },
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        color: AppColors.bgSecondary.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getQualityColor(quality).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getQualityColor(quality).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$quality',
                  style: AppTextStyles.h4.copyWith(
                    color: _getQualityColor(quality),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat.jm().format(session.bedTime.toLocal())} - ${DateFormat.jm().format(wakeTime.toLocal())}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${hours}h ${minutes}m',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentPrimary,
                  ),
                ),
                Text(
                  'Sleep',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(int quality) {
    if (quality >= 4) return AppColors.accentSuccess;
    if (quality >= 3) return AppColors.accentAmber;
    return AppColors.accentPrimary;
  }
}
