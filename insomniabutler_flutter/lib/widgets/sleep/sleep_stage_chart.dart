import 'package:flutter/material.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';
import 'package:intl/intl.dart';

class SleepStageChart extends StatelessWidget {
  final SleepSession session;

  const SleepStageChart({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final hasStageData = session.deepSleepDuration != null ||
        session.lightSleepDuration != null ||
        session.remSleepDuration != null;

    if (!hasStageData) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sleep Stages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Stage bars
          _buildStageBar(),
          const SizedBox(height: 20),

          // Stage breakdown
          _buildStageBreakdown(),
        ],
      ),
    );
  }

  Widget _buildStageBar() {
    final deep = session.deepSleepDuration ?? 0;
    final light = session.lightSleepDuration ?? 0;
    final rem = session.remSleepDuration ?? 0;
    final awake = session.awakeDuration ?? 0;
    final unspecified = session.unspecifiedSleepDuration ?? 0;

    final total = deep + light + rem + awake + unspecified;

    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        // Visual bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              if (deep > 0)
                Expanded(
                  flex: deep,
                  child: Container(
                    height: 40,
                    color: const Color(0xFF4A90E2),
                  ),
                ),
              if (light > 0)
                Expanded(
                  flex: light,
                  child: Container(
                    height: 40,
                    color: const Color(0xFF7ED321),
                  ),
                ),
              if (rem > 0)
                Expanded(
                  flex: rem,
                  child: Container(
                    height: 40,
                    color: const Color(0xFFBD10E0),
                  ),
                ),
              if (awake > 0)
                Expanded(
                  flex: awake,
                  child: Container(
                    height: 40,
                    color: const Color(0xFFF5A623),
                  ),
                ),
              if (unspecified > 0)
                Expanded(
                  flex: unspecified,
                  child: Container(
                    height: 40,
                    color: const Color(0xFF9B9B9B),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('HH:mm').format(session.bedTime),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            if (session.wakeTime != null)
              Text(
                DateFormat('HH:mm').format(session.wakeTime!),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStageBreakdown() {
    return Column(
      children: [
        if (session.deepSleepDuration != null)
          _buildStageLegendItem(
            'Deep Sleep',
            session.deepSleepDuration!,
            const Color(0xFF4A90E2),
            Icons.bedtime,
          ),
        if (session.lightSleepDuration != null)
          _buildStageLegendItem(
            'Light Sleep',
            session.lightSleepDuration!,
            const Color(0xFF7ED321),
            Icons.nights_stay,
          ),
        if (session.remSleepDuration != null)
          _buildStageLegendItem(
            'REM Sleep',
            session.remSleepDuration!,
            const Color(0xFFBD10E0),
            Icons.psychology,
          ),
        if (session.awakeDuration != null)
          _buildStageLegendItem(
            'Awake',
            session.awakeDuration!,
            const Color(0xFFF5A623),
            Icons.visibility,
          ),
        if (session.unspecifiedSleepDuration != null)
          _buildStageLegendItem(
            'Sleep',
            session.unspecifiedSleepDuration!,
            const Color(0xFF9B9B9B),
            Icons.hotel,
          ),
      ],
    );
  }

  Widget _buildStageLegendItem(
    String label,
    int minutes,
    Color color,
    IconData icon,
  ) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            timeStr,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
