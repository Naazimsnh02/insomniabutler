import 'dart:math';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart' as protocol;
import '../services/embedding_service.dart';

class DevEndpoint extends Endpoint {
  Future<bool> generateRealisticData(Session session, int userId) async {
    final random = Random();
    final now = DateTime.now().toUtc();

    // Get API key for embeddings
    var apiKey = session.passwords['geminiApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = Platform.environment['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      session.log('Warning: No Gemini API key found. Embeddings will be skipped.');
    }

    final embeddingService = apiKey != null ? EmbeddingService(apiKey) : null;

    // Professional journal content templates
    final journalTemplates = [
      {
        'title': 'Productive Day',
        'content': 'Completed three major tasks today including the quarterly report. Feeling accomplished and ready to rest. Looking forward to tomorrow\'s team meeting.',
        'mood': 'Happy'
      },
      {
        'title': 'Mindful Evening',
        'content': 'Practiced 20 minutes of meditation after work. The breathing exercises really helped clear my mind. Grateful for these quiet moments.',
        'mood': 'Calm'
      },
      {
        'title': 'Workout Recovery',
        'content': 'Hit a new personal record at the gym today. Muscles are sore but it\'s a good kind of tired. Hydrated well and ready for deep sleep.',
        'mood': 'Tired'
      },
      {
        'title': 'Work Reflections',
        'content': 'The presentation went better than expected. Client seemed impressed with our proposal. Need to follow up with the team tomorrow.',
        'mood': 'Happy'
      },
      {
        'title': 'Self-Care Day',
        'content': 'Took time for myself today - read a book, went for a walk, cooked a healthy meal. Sometimes slowing down is exactly what I need.',
        'mood': 'Calm'
      },
      {
        'title': 'Planning Ahead',
        'content': 'Organized my schedule for the upcoming week. Having a clear plan reduces my anxiety. Tomorrow starts with a morning run.',
        'mood': 'Calm'
      },
      {
        'title': 'Creative Flow',
        'content': 'Spent the evening working on my side project. Lost track of time in the best way. Excited to see where this goes.',
        'mood': 'Happy'
      },
      {
        'title': 'Challenging Day',
        'content': 'Today was tough with back-to-back meetings and tight deadlines. But I managed to push through. Tomorrow will be better.',
        'mood': 'Blah'
      },
      {
        'title': 'Nature Connection',
        'content': 'Evening walk in the park was exactly what I needed. Fresh air and greenery always help me decompress. Saw a beautiful sunset.',
        'mood': 'Calm'
      },
      {
        'title': 'Learning Journey',
        'content': 'Finished two chapters of that technical book. The concepts are starting to click. Continuous learning keeps me motivated.',
        'mood': 'Happy'
      },
      {
        'title': 'Social Energy',
        'content': 'Had dinner with friends tonight. Good conversations and laughter. Feeling recharged from quality time with people I care about.',
        'mood': 'Happy'
      },
      {
        'title': 'Quiet Reflection',
        'content': 'Sometimes I just need a quiet evening at home. Watched a documentary, had some tea. Simple pleasures matter.',
        'mood': 'Calm'
      },
      {
        'title': 'Progress Check',
        'content': 'Reviewed my goals for the month. Making steady progress on most fronts. Adjusting a few priorities for next week.',
        'mood': 'Calm'
      },
      {
        'title': 'Energy Dip',
        'content': 'Feeling a bit low on energy today. Might be the weather or just need more rest. Listening to my body and taking it easy.',
        'mood': 'Tired'
      },
      {
        'title': 'Family Time',
        'content': 'Video call with family was heartwarming. Miss them but grateful for technology that keeps us connected. Shared some good news.',
        'mood': 'Happy'
      },
    ];

    // Professional chat conversation templates
    final chatConversations = [
      {
        'user': 'I keep replaying tomorrow\'s presentation in my head. What if I forget my key points?',
        'ai': 'That\'s a common worry before important presentations. Let\'s use a technique: imagine you\'ve already given the presentation successfully. What would that feel like? Also, your preparation has already happened - trust in that work.'
      },
      {
        'user': 'My to-do list for tomorrow is overwhelming. I don\'t know where to start.',
        'ai': 'Let\'s break this down together. What are the top 3 must-do items? We can capture them here so your mind can release them for tonight. Everything else can wait until morning when you\'re fresh.'
      },
      {
        'user': 'I had a difficult conversation with a colleague today and I can\'t stop thinking about it.',
        'ai': 'Difficult conversations can linger in our minds. What specifically is bothering you - what was said, or how it was said? Sometimes naming the specific concern helps us process it.'
      },
      {
        'user': 'I\'m worried about my health. I\'ve been feeling tired lately.',
        'ai': 'Health concerns are important, but nighttime worry rarely leads to solutions. Have you scheduled a check-up? If yes, trust that you\'ve taken action. If not, let\'s make a note to do that tomorrow. For now, rest is actually helping your health.'
      },
      {
        'user': 'Just feeling anxious and I don\'t even know why.',
        'ai': 'Free-floating anxiety is real and valid. Let\'s try a grounding exercise together. Can you name 5 things you can see right now? This helps anchor us in the present moment.'
      },
      {
        'user': 'I keep thinking about a mistake I made at work last week.',
        'ai': 'Our minds often replay past events, especially mistakes. What did you learn from this experience? Growth comes from reflection, not rumination. You\'ve likely already grown from this - let\'s acknowledge that.'
      },
      {
        'user': 'Tomorrow is a big day and I need to be well-rested, but I can\'t sleep.',
        'ai': 'The pressure to sleep can actually make it harder. Let\'s shift focus: instead of trying to sleep, let\'s aim for deep relaxation. Your body knows how to transition from relaxation to sleep naturally.'
      },
      {
        'user': 'I\'m thinking about a project deadline next week. There\'s so much to do.',
        'ai': 'Project anxiety is common. Let\'s separate what you can control tonight (nothing) from what you can control tomorrow (your focused work). Would it help to write down your first task for tomorrow?'
      },
      {
        'user': 'I feel like I\'m not doing enough, not achieving enough.',
        'ai': 'That\'s a heavy thought to carry into sleep. Let\'s reframe: what did you accomplish today, even small things? Our culture often overlooks daily progress in favor of big wins. You deserve credit for showing up.'
      },
      {
        'user': 'I\'m worried about money and bills.',
        'ai': 'Financial stress is very real. Are there any bills due tonight that need immediate action? If not, let\'s acknowledge that worrying now won\'t change tomorrow\'s finances, but rest will help you think more clearly about solutions.'
      },
      {
        'user': 'I can\'t stop scrolling through social media and comparing myself to others.',
        'ai': 'Social comparison is exhausting and rarely accurate - people share highlights, not struggles. What would it feel like to put the phone down and do something kind for yourself right now?'
      },
      {
        'user': 'I\'m thinking about a relationship issue. Should I have said something different?',
        'ai': 'Relationship replay is common. The past conversation is done - you can\'t change it. But you can choose how to approach future conversations. Would it help to plan what you might say next time?'
      },
      {
        'user': 'I feel restless and my mind won\'t quiet down.',
        'ai': 'Mental restlessness often means your mind is processing the day. Let\'s try a progressive muscle relaxation - starting with your toes, tense and release each muscle group. This signals your body it\'s time to wind down.'
      },
      {
        'user': 'I\'m worried I won\'t wake up on time tomorrow.',
        'ai': 'Have you set your alarm? If yes, trust your systems. If you\'d like extra assurance, you could set a backup alarm. But worrying about it won\'t help - your alarm will do its job.'
      },
      {
        'user': 'I keep thinking about everything I need to do this week.',
        'ai': 'Week-ahead anxiety is overwhelming because you\'re trying to solve multiple days at once. Let\'s focus just on tomorrow. What\'s the one thing that would make tomorrow feel successful?'
      },
    ];

    // Diverse thought categories and content
    final thoughtData = {
      'Work': [
        'Need to finish the quarterly report by Friday',
        'Presentation for the client meeting needs more polish',
        'Should I bring up the budget concerns in tomorrow\'s standup?',
        'The new project timeline seems too aggressive',
        'Need to respond to those emails first thing tomorrow',
        'Wondering if I should apply for that senior position',
      ],
      'Health': [
        'Should schedule that doctor\'s appointment I\'ve been putting off',
        'Need to be more consistent with my workout routine',
        'Thinking about trying that new meal prep strategy',
        'My sleep schedule has been off lately',
        'Should I start taking those vitamins the doctor recommended?',
        'Need to drink more water throughout the day',
      ],
      'Relationships': [
        'Need to call mom this weekend, it\'s been too long',
        'Should I reach out to my friend about that misunderstanding?',
        'Planning a date night - need to make reservations',
        'Thinking about how to support my partner better',
        'Need to respond to those messages from college friends',
        'Should organize a get-together with the team',
      ],
      'Finance': [
        'Need to review my budget for next month',
        'Should I increase my retirement contributions?',
        'That unexpected expense threw off my savings plan',
        'Thinking about whether to invest in that opportunity',
        'Need to track my spending more carefully',
        'Should I negotiate a raise at my next review?',
      ],
      'Personal Growth': [
        'Want to finish reading that book on leadership',
        'Should I enroll in that online course?',
        'Need to practice more patience in stressful situations',
        'Thinking about starting a meditation practice',
        'Want to develop better time management skills',
        'Should I start journaling more consistently?',
      ],
      'Future Planning': [
        'Wondering where I want to be in my career in 5 years',
        'Should I start looking for a new apartment?',
        'Thinking about planning a vacation for next quarter',
        'Need to update my professional goals',
        'Should I start that side project I\'ve been considering?',
        'Thinking about what skills I want to develop next year',
      ],
      'Home & Life': [
        'Need to organize the closet this weekend',
        'Should I finally fix that leaky faucet?',
        'Thinking about redecorating the living room',
        'Need to meal plan for the week',
        'Should I get a gym membership or workout at home?',
        'Want to establish a better morning routine',
      ],
    };

    await session.db.transaction((transaction) async {
      session.log('Starting data generation for 30 days...');
      
      // Collections to store data for batch embedding generation
      final chatMessagesToEmbed = <String>[];
      final chatMessageRecords = <protocol.ChatMessage>[];
      final journalEntriesToEmbed = <String>[];
      final journalEntryRecords = <protocol.JournalEntry>[];
      
      // Generate data for the last 30 days
      for (int i = 30; i >= 1; i--) {
        final date = now.subtract(Duration(days: i));

        // 1. Generate Sleep Session with realistic patterns
        final bedtime = DateTime.utc(
          date.year,
          date.month,
          date.day,
          22,
          random.nextInt(90),
        );

        final wakeTime = bedtime.add(
          Duration(
            hours: 7 + random.nextInt(2),
            minutes: random.nextInt(60),
          ),
        );

        final sleepDurationMinutes = wakeTime.difference(bedtime).inMinutes;

        final deepMinutes =
            (sleepDurationMinutes * (0.15 + random.nextDouble() * 0.1)).round();
        final remMinutes =
            (sleepDurationMinutes * (0.2 + random.nextDouble() * 0.05)).round();
        final awakeMinutes =
            (sleepDurationMinutes * (0.05 + random.nextDouble() * 0.05)).round();
        final lightMinutes =
            sleepDurationMinutes - deepMinutes - remMinutes - awakeMinutes;

        final usedButler = random.nextDouble() < 0.7;

        final sleepLatency = usedButler
            ? 5 + random.nextInt(10)
            : 25 + random.nextInt(25);

        final sleepQuality = usedButler
            ? 4 + random.nextInt(2)
            : 2 + random.nextInt(3);

        final moods = ['Happy', 'Calm', 'Tired', 'Blah', 'Sad'];
        final morningMood = moods[random.nextInt(moods.length)];

        final sessionRecord = protocol.SleepSession(
          userId: userId,
          bedTime: bedtime,
          wakeTime: wakeTime,
          sleepQuality: sleepQuality,
          morningMood: morningMood,
          sleepLatencyMinutes: sleepLatency,
          usedButler: usedButler,
          thoughtsProcessed: usedButler ? 1 + random.nextInt(4) : 0,
          sessionDate: bedtime,
          deepSleepDuration: deepMinutes,
          lightSleepDuration: lightMinutes,
          remSleepDuration: remMinutes,
          awakeDuration: awakeMinutes,
          restingHeartRate: 50 + random.nextInt(20),
          hrv: 30 + random.nextInt(70),
          respiratoryRate: 12 + random.nextInt(6),
          interruptions: sleepQuality >= 4 ? random.nextInt(2) : random.nextInt(4),
        );

        final savedSession = await protocol.SleepSession.db.insertRow(
          session,
          sessionRecord,
          transaction: transaction,
        );

        // 2. Prepare Chat Messages for batch embedding
        if (usedButler) {
          final conversation = chatConversations[random.nextInt(chatConversations.length)];
          
          final userContent = conversation['user']!;
          final aiContent = conversation['ai']!;
          
          // Store for batch embedding
          chatMessagesToEmbed.add(userContent);
          chatMessagesToEmbed.add(aiContent);
          
          // Create records (embeddings will be added later)
          chatMessageRecords.add(protocol.ChatMessage(
            userId: userId,
            sessionId: savedSession.id.toString(),
            role: 'user',
            content: userContent,
            timestamp: bedtime.subtract(const Duration(minutes: 5)),
          ));
          
          chatMessageRecords.add(protocol.ChatMessage(
            userId: userId,
            sessionId: savedSession.id.toString(),
            role: 'ai',
            content: aiContent,
            timestamp: bedtime.subtract(const Duration(minutes: 4)),
          ));
        }

        // 3. Prepare Journal Entries for batch embedding
        if (random.nextDouble() < 0.75) {
          final journalTemplate = journalTemplates[random.nextInt(journalTemplates.length)];
          final journalContent = '${journalTemplate['title']} ${journalTemplate['content']}';
          
          // Store for batch embedding
          journalEntriesToEmbed.add(journalContent);
          
          // Create record (embedding will be added later)
          journalEntryRecords.add(protocol.JournalEntry(
            userId: userId,
            title: journalTemplate['title']!,
            content: journalTemplate['content']!,
            mood: journalTemplate['mood']!,
            sleepSessionId: savedSession.id,
            createdAt: bedtime.subtract(const Duration(minutes: 15)),
            updatedAt: bedtime.subtract(const Duration(minutes: 15)),
            entryDate: bedtime,
          ));
        }

        // 4. Generate Thought Logs
        if (sessionRecord.thoughtsProcessed > 0) {
          final categories = thoughtData.keys.toList();
          
          for (int t = 0; t < sessionRecord.thoughtsProcessed; t++) {
            final category = categories[random.nextInt(categories.length)];
            final thoughts = thoughtData[category]!;
            final content = thoughts[random.nextInt(thoughts.length)];

            await protocol.ThoughtLog.db.insertRow(
              session,
              protocol.ThoughtLog(
                userId: userId,
                sessionId: savedSession.id,
                category: category,
                content: content,
                timestamp: bedtime.subtract(Duration(minutes: 5 + t * 2)),
                resolved: random.nextBool(),
                readinessIncrease: 2 + random.nextInt(5),
              ),
              transaction: transaction,
            );
          }
        }

        // 5. Generate Sleep Insights
        if (i % 3 == 0 || i % 4 == 0) {
          final insightTypes = ['quality', 'consistency', 'latency', 'duration'];
          final insightType = insightTypes[random.nextInt(insightTypes.length)];
          
          String metric = '';
          double value = 0;
          String description = '';

          switch (insightType) {
            case 'quality':
              metric = 'Sleep Quality';
              value = sleepQuality.toDouble();
              description = sleepQuality >= 4
                  ? 'Your sleep quality is excellent! Keep up the good work.'
                  : 'Your sleep quality could improve. Consider using the Butler to process thoughts before bed.';
              break;
            case 'consistency':
              metric = 'Bedtime Consistency';
              value = random.nextDouble() * 100;
              description = value > 70
                  ? 'You\'re maintaining a consistent sleep schedule. This helps regulate your circadian rhythm.'
                  : 'Try to maintain a more consistent bedtime to improve sleep quality.';
              break;
            case 'latency':
              metric = 'Sleep Latency';
              value = sleepLatency.toDouble();
              description = sleepLatency < 15
                  ? 'You\'re falling asleep quickly! The Butler seems to be helping.'
                  : 'It\'s taking you longer to fall asleep. Consider using thought-clearing techniques.';
              break;
            case 'duration':
              metric = 'Sleep Duration';
              value = sleepDurationMinutes / 60.0;
              description = value >= 7
                  ? 'You\'re getting adequate sleep duration. Great job!'
                  : 'Try to get at least 7-8 hours of sleep for optimal health.';
              break;
          }

          await protocol.SleepInsight.db.insertRow(
            session,
            protocol.SleepInsight(
              userId: userId,
              insightType: insightType,
              metric: metric,
              value: value,
              description: description,
              generatedAt: bedtime.add(const Duration(hours: 8)),
            ),
            transaction: transaction,
          );
        }
      }
      
      // BATCH GENERATE EMBEDDINGS - Much faster!
      session.log('Generating embeddings in batches for ${chatMessagesToEmbed.length} chat messages and ${journalEntriesToEmbed.length} journal entries...');
      
      if (embeddingService != null) {
        try {
          // Generate all chat message embeddings in one batch
          if (chatMessagesToEmbed.isNotEmpty) {
            session.log('Batch generating ${chatMessagesToEmbed.length} chat embeddings...');
            final chatEmbeddings = await embeddingService.generateBatchEmbeddings(chatMessagesToEmbed);
            
            // Assign embeddings to chat message records
            for (int i = 0; i < chatMessageRecords.length; i++) {
              if (i < chatEmbeddings.length) {
                chatMessageRecords[i].embedding = Vector(chatEmbeddings[i]);
              }
            }
            session.log('Chat embeddings generated successfully!');
          }
          
          // Generate all journal entry embeddings in one batch
          if (journalEntriesToEmbed.isNotEmpty) {
            session.log('Batch generating ${journalEntriesToEmbed.length} journal embeddings...');
            final journalEmbeddings = await embeddingService.generateBatchEmbeddings(journalEntriesToEmbed);
            
            // Assign embeddings to journal entry records
            for (int i = 0; i < journalEntryRecords.length; i++) {
              if (i < journalEmbeddings.length) {
                journalEntryRecords[i].embedding = Vector(journalEmbeddings[i]);
              }
            }
            session.log('Journal embeddings generated successfully!');
          }
        } catch (e) {
          session.log('Warning: Failed to generate batch embeddings: $e');
          session.log('Continuing without embeddings...');
        }
      }
      
      // Insert all chat messages with embeddings
      for (final chatMessage in chatMessageRecords) {
        await protocol.ChatMessage.db.insertRow(
          session,
          chatMessage,
          transaction: transaction,
        );
      }
      
      // Insert all journal entries with embeddings
      for (final journalEntry in journalEntryRecords) {
        await protocol.JournalEntry.db.insertRow(
          session,
          journalEntry,
          transaction: transaction,
        );
      }
      
      session.log('Data generation complete! Generated 30 days of comprehensive data with batch-generated embeddings.');
    });

    return true;
  }

  Future<bool> clearUserData(Session session, int userId) async {
    await session.db.transaction((transaction) async {
      await protocol.ChatMessage.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.ThoughtLog.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.JournalEntry.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.SleepInsight.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.SleepSession.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
    });
    return true;
  }

  /// Generates embeddings for all historical data that doesn't have them
  Future<Map<String, int>> backfillEmbeddings(Session session) async {
    var apiKey = session.passwords['geminiApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = Platform.environment['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found');
    }

    final embeddingService = EmbeddingService(apiKey);
    int journalCount = 0;
    int chatCount = 0;

    // 1. Backfill Journal Entries in batches
    final allJournalEntries = await protocol.JournalEntry.db.find(session);
    final journalEntries = allJournalEntries.where((e) => e.embedding == null).toList();

    session.log('Backfilling ${journalEntries.length} journal entries in batches...');
    
    if (journalEntries.isNotEmpty) {
      final texts = journalEntries.map((e) => '${e.title ?? ''} ${e.content}').toList();
      final embeddings = await embeddingService.generateBatchEmbeddings(texts);
      
      for (int i = 0; i < journalEntries.length; i++) {
        if (i < embeddings.length) {
          journalEntries[i].embedding = Vector(embeddings[i]);
          await protocol.JournalEntry.db.updateRow(session, journalEntries[i]);
          journalCount++;
        }
      }
    }

    // 2. Backfill Chat Messages in batches
    final allChatMessages = await protocol.ChatMessage.db.find(session);
    final chatMessages = allChatMessages.where((m) => m.embedding == null).toList();

    session.log('Backfilling ${chatMessages.length} chat messages in batches...');
    
    if (chatMessages.isNotEmpty) {
      final texts = chatMessages.map((m) => m.content).toList();
      final embeddings = await embeddingService.generateBatchEmbeddings(texts);
      
      for (int i = 0; i < chatMessages.length; i++) {
        if (i < embeddings.length) {
          chatMessages[i].embedding = Vector(embeddings[i]);
          await protocol.ChatMessage.db.updateRow(session, chatMessages[i]);
          chatCount++;
        }
      }
    }

    return {
      'journal_entries_processed': journalCount,
      'chat_messages_processed': chatCount,
    };
  }
}
