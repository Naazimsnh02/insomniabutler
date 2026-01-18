import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'manual_log_screen.dart';

class SleepHistoryScreen extends StatefulWidget {
  const SleepHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SleepHistoryScreen> createState() => _SleepHistoryScreenState();
}

class _SleepHistoryScreenState extends State<SleepHistoryScreen> {
  // Mock data for demo - will be replaced with real backend calls
  final List<Map<String, dynamic>> _sessions = [
    {
      'sessionDate': DateTime.now().subtract(const Duration(days: 1)),
      'bedTime': DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      'wakeTime': DateTime.now().subtract(const Duration(days: 1)),
      'sleepQuality': 4,
    },
    {
      'sessionDate': DateTime.now().subtract(const Duration(days: 2)),
      'bedTime': DateTime.now().subtract(const Duration(days: 2, hours: 7)),
      'wakeTime': DateTime.now().subtract(const Duration(days: 2)),
      'sleepQuality': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgPrimary),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _sessions.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.containerPadding),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) => _buildSessionCard(_sessions[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualLogScreen())),
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(backgroundColor: AppColors.glassBg),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('Sleep Sessions', style: AppTextStyles.h4),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nightlight_outlined, size: 64, color: AppColors.textTertiary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Text('No sessions logged yet', style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final dateStr = DateFormat('EEE, MMM d').format(session['sessionDate']);
    final duration = session['wakeTime'].difference(session['bedTime']);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onTap: () {
          HapticHelper.lightImpact();
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => ManualLogScreen(initialData: session))
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getQualityColor(session['sleepQuality']).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${session['sleepQuality']}',
                style: AppTextStyles.h4.copyWith(
                  color: _getQualityColor(session['sleepQuality']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    '${DateFormat.jm().format(session['bedTime'])} - ${DateFormat.jm().format(session['wakeTime'])}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${hours}h ${minutes}m', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                Text('Duration', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
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
