import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class DevEndpoint extends Endpoint {
  Future<bool> generateRealisticData(Session session, int userId) async {
    final random = Random();
    final now = DateTime.now().toUtc();
    
    // Generate data for the last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      
      // 1. Generate Sleep Session
      // Bedtime between 10 PM and 11:30 PM
      final bedtime = DateTime(
        date.year,
        date.month,
        date.day,
        22,
        random.nextInt(90),
      ).toUtc();
      
      // Wake time between 6 AM and 8 AM
      final wakeTime = bedtime.add(Duration(
        hours: 7 + random.nextInt(2),
        minutes: random.nextInt(60),
      ));
      
      final sleepDurationMinutes = wakeTime.difference(bedtime).inMinutes;
      
      // Realistic sleep stages (percentages)
      // Deep: 15-25%, REM: 20-25%, Light: 40-55%, Awake: 5-10%
      final deepMinutes = (sleepDurationMinutes * (0.15 + random.nextDouble() * 0.1)).round();
      final remMinutes = (sleepDurationMinutes * (0.2 + random.nextDouble() * 0.05)).round();
      final awakeMinutes = (sleepDurationMinutes * (0.05 + random.nextDouble() * 0.05)).round();
      final lightMinutes = sleepDurationMinutes - deepMinutes - remMinutes - awakeMinutes;
      
      final sleepQuality = 60 + random.nextInt(35); // 60-95
      final moods = ['Refreshed', 'Calm', 'A bit tired', 'Energetic', 'Restored'];
      final morningMood = moods[random.nextInt(moods.length)];
      
      final sessionRecord = SleepSession(
        userId: userId,
        bedTime: bedtime,
        wakeTime: wakeTime,
        sleepQuality: sleepQuality,
        morningMood: morningMood,
        sleepLatencyMinutes: 10 + random.nextInt(20),
        usedButler: random.nextBool(),
        thoughtsProcessed: random.nextInt(5),
        sessionDate: bedtime,
        deepSleepDuration: deepMinutes,
        lightSleepDuration: lightMinutes,
        remSleepDuration: remMinutes,
        awakeDuration: awakeMinutes,
        restingHeartRate: 55 + random.nextInt(15), // 55-70
        hrv: 40 + random.nextInt(40), // 40-80
        respiratoryRate: 12 + random.nextInt(6), // 12-18
      );
      
      final savedSession = await SleepSession.db.insertRow(session, sessionRecord);
      
      // 2. Generate Journal Entry for ~70% of days
      if (random.nextDouble() < 0.7) {
        final journalMoods = ['Great', 'Good', 'Neutral', 'Anxious', 'Tired'];
        final mood = journalMoods[random.nextInt(journalMoods.length)];
        
        final contents = [
          "Had a productive day today. Feeling ready for sleep.",
          "A bit stressed about work, but trying to unwind.",
          "Spent some time outdoors today, which usually helps me sleep better.",
          "Drank coffee a bit late in the afternoon, hope it doesn't affect my sleep.",
          "Feeling very peaceful tonight after the meditation session.",
          "Tomorrow is going to be busy, but I've planned everything out.",
          "Read a book for 30 minutes before bed. Very relaxing.",
          "Workout was intense today. Body feels tired but in a good way."
        ];
        
        final journalEntry = JournalEntry(
          userId: userId,
          title: "Evening Reflection",
          content: contents[random.nextInt(contents.length)],
          mood: mood,
          sleepSessionId: savedSession.id,
          createdAt: bedtime.subtract(const Duration(minutes: 15)),
          updatedAt: bedtime.subtract(const Duration(minutes: 15)),
          entryDate: bedtime,
        );
        
        await JournalEntry.db.insertRow(session, journalEntry);
      }
      
      // 3. Generate Thought Logs for each session
      if (sessionRecord.thoughtsProcessed > 0) {
        final thoughtCategories = ['Work', 'Health', 'Future', 'Relationships', 'To-do'];
        final thoughtContents = [
          "Thinking about the upcoming project deadline.",
          "Wondering if I should start a new workout routine.",
          "Reminiscing about the trip last summer.",
          "Planning what to cook for dinner tomorrow.",
          "Worried about a conversation I had earlier today."
        ];
        
        for (int t = 0; t < sessionRecord.thoughtsProcessed; t++) {
          final thoughtLog = ThoughtLog(
            userId: userId,
            sessionId: savedSession.id,
            category: thoughtCategories[random.nextInt(thoughtCategories.length)],
            content: thoughtContents[random.nextInt(thoughtContents.length)],
            timestamp: bedtime.subtract(Duration(minutes: 5 + t * 2)),
            resolved: random.nextBool(),
            readinessIncrease: 2 + random.nextInt(5),
          );
          await ThoughtLog.db.insertRow(session, thoughtLog);
        }
      }
    }
    
    return true;
  }
}
