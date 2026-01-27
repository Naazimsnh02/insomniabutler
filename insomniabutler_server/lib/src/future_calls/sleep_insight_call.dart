import 'package:serverpod/serverpod.dart';
import '../services/insight_service.dart';
import '../generated/protocol.dart';

class SleepInsightCall extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    final wrapper = object as IntWrapper?;
    if (wrapper == null) return;
    final userId = wrapper.value;

    await InsightService.generateSleepInsights(session, userId);

    // Schedule the next one for 24 hours from now
    final user = await User.db.findById(session, userId);
    if (user != null && user.sleepInsightsEnabled) {
      await session.serverpod.futureCallWithDelay(
        'SleepInsightCall',
        IntWrapper(value: userId),
        const Duration(hours: 24),
      );
    }
  }
}
