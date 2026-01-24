# Super Butler Implementation Plan

## Overview
Transform Insomnia Butler from a stateless chatbot into a context-aware AI agent with:
- **Long-term memory** via vector embeddings
- **Multi-turn conversations** with full history
- **Tool use** to query user data and execute actions
- **Semantic search** across journals and chat history

---

## Architecture Components

### 1. Vector Database (pgvector)
**Status:** ✅ Migration created

**What it does:**
- Stores 768-dimensional embeddings for journal entries and chat messages
- Enables semantic search (find entries by meaning, not just keywords)
- Uses HNSW indexing for fast similarity queries

**Models:**
- Embedding Model: `gemini-embedding-1.0` (Gemini)
- Dimensions: 768 (optimal balance of quality and performance)
- Distance Metric: Cosine similarity

### 2. Enhanced Services

#### EmbeddingService
**Location:** `lib/src/services/embedding_service.dart`

**Capabilities:**
- Generate embeddings for single texts
- Batch embedding generation (efficient for bulk operations)
- Query-optimized embeddings (TaskType.retrievalQuery)
- Cosine similarity calculations

**Usage:**
```dart
final embedding = await embeddingService.generateEmbedding(journalContent);
final queryEmbed = await embeddingService.generateQueryEmbedding("work stress");
```

#### GeminiService (Upgraded)
**Location:** `lib/src/services/gemini_service.dart`

**New Features:**
- Model: `gemini-2.5-flash-lite` (supports function calling)
- System instruction with CBT-I principles
- Three built-in tools:
  1. `query_sleep_history` - Analyze sleep patterns
  2. `search_memories` - Semantic search across journals/chats
  3. `execute_action` - Trigger app actions

**Conversation Flow:**
```dart
final response = await geminiService.sendMessageWithHistory(
  history: previousMessages,
  userMessage: "I'm worried about tomorrow's presentation",
);
```

#### ToolExecutor
**Location:** `lib/src/services/tool_executor.dart`

**Responsibilities:**
- Execute AI-requested function calls
- Query database for sleep statistics
- Perform vector similarity searches
- Queue actions for client execution

---

## Implementation Phases

### Phase 1: Database Setup ✅
**Files Modified:**
- `journal_entry.spy.yaml` - Added `embedding` field
- `chat_message.spy.yaml` - Added `embedding` field
- `ai_action.spy.yaml` - New protocol for actions
- `thought_response.spy.yaml` - Added `action` and `metadata` fields
- `00004_add_vector_embeddings.sql` - Migration script

**Next Steps:**
1. Run `serverpod generate` to regenerate protocol
2. Run migration: `.\run-migrations.ps1`

### Phase 2: Refactor ThoughtClearingEndpoint
**Current State:** Uses simple string-based prompts, no history

**Target State:**
```dart
Future<ThoughtResponse> processThought(...) async {
  // 1. Fetch conversation history
  final history = await _buildConversationHistory(sessionId);
  
  // 2. Send to Gemini with tools
  final response = await gemini.sendMessageWithHistory(
    history: history,
    userMessage: userMessage,
  );
  
  // 3. Handle function calls
  AIAction? action;
  String finalMessage = response.text ?? '';
  
  for (final part in response.candidates.first.content.parts) {
    if (part is FunctionCall) {
      final result = await toolExecutor.executeTool(
        part.name,
        part.args,
      );
      
      // Send result back to model for final response
      final followUp = await chat.sendMessage(
        Content.model([FunctionResponse(part.name, result)])
      );
      finalMessage = followUp.text ?? '';
      
      // Extract action if it was execute_action
      if (part.name == 'execute_action') {
        action = _parseAction(result);
      }
    }
  }
  
  // 4. Generate and store embeddings
  final embedding = await embeddingService.generateEmbedding(userMessage);
  
  // 5. Save messages with embeddings
  await ChatMessage.db.insertRow(..., embedding: embedding);
  
  return ThoughtResponse(
    message: finalMessage,
    category: category,
    newReadiness: newReadiness,
    action: action,
  );
}
```

### Phase 3: Background Embedding Generation
**Challenge:** Existing journal entries and chat messages don't have embeddings

**Solution:** Create a background job
```dart
// lib/src/services/embedding_backfill_service.dart
class EmbeddingBackfillService {
  Future<void> backfillJournalEmbeddings() async {
    final entries = await JournalEntry.db.find(
      session,
      where: (t) => t.embedding.isNull(),
      limit: 100, // Process in batches
    );
    
    final texts = entries.map((e) => '${e.title ?? ''} ${e.content}').toList();
    final embeddings = await embeddingService.generateBatchEmbeddings(texts);
    
    for (var i = 0; i < entries.length; i++) {
      entries[i].embedding = '[${embeddings[i].join(',')}]';
      await JournalEntry.db.updateRow(session, entries[i]);
    }
  }
}
```

### Phase 4: Flutter Client Integration
**File:** `insomniabutler_flutter/lib/screens/insomnia_butler_screen.dart`

**Changes Needed:**
1. Handle `ThoughtResponse.action` field
2. Implement action dispatcher:

```dart
void _handleAIResponse(ThoughtResponse response) {
  // Display message
  setState(() {
    _messages.add(ChatMessage(
      role: 'assistant',
      content: response.message,
    ));
  });
  
  // Execute action if present
  if (response.action != null) {
    _executeAction(response.action!);
  }
}

Future<void> _executeAction(AIAction action) async {
  switch (action.command) {
    case 'play_sound':
      final params = jsonDecode(action.parameters ?? '{}');
      final soundName = params['sound_name'] as String;
      await _audioPlayer.play(soundName);
      break;
      
    case 'set_reminder':
      final params = jsonDecode(action.parameters ?? '{}');
      await _notificationService.scheduleReminder(params);
      break;
      
    // ... other actions
  }
}
```

---

## Testing Strategy

### 1. Unit Tests
- `EmbeddingService`: Test embedding generation and similarity
- `ToolExecutor`: Mock database queries, verify JSON output
- `GeminiService`: Test conversation history building

### 2. Integration Tests
- End-to-end conversation with tool calls
- Vector search accuracy
- Action execution flow

### 3. Manual Testing Scenarios
**Scenario 1: Memory Recall**
```
User: "I'm stressed about work again"
AI: [Calls search_memories("work stress")]
AI: "I see you mentioned work stress in your journal on Jan 15th. 
     You wrote about the deadline pressure. Is this related?"
```

**Scenario 2: Sleep Insights**
```
User: "I can't sleep"
AI: [Calls query_sleep_history(7)]
AI: "Looking at your sleep data, you've had 4+ interruptions 
     for the past 3 nights. Would you like me to play the 
     Rain sound to help you relax?"
User: "Yes"
AI: [Calls execute_action("play_sound", {"sound_name": "Rain"})]
AI: "I've started the Rain sound for you. Focus on your breathing..."
```

---

## Performance Considerations

### Vector Search Optimization
- **Index Type:** HNSW (Hierarchical Navigable Small World)
  - Faster than IVFFlat for high-dimensional data
  - Parameters: `m=16, ef_construction=64`
  - Trade-off: Slightly larger index, much faster queries

### Embedding Caching
- Store embeddings in database (not regenerate each time)
- Only generate embeddings for new content
- Batch operations for efficiency

### Query Limits
- Limit vector search to top 5-10 results
- Limit conversation history to last 20 messages
- Use pagination for large datasets

---

## Security & Privacy

### Data Protection
- Embeddings are stored locally in user's database
- No embeddings sent to external services (only text)
- Vector search is user-scoped (WHERE user_id = ...)

### API Key Management
- Gemini API key stored in `passwords.yaml`
- Never exposed to client
- Rate limiting on endpoint

---

## Rollout Plan

### Week 1: Foundation
- ✅ Create services and protocols
- ✅ Write migration
- ⏳ Run migration on dev database
- ⏳ Generate Serverpod code

### Week 2: Backend Integration
- Refactor `ThoughtClearingEndpoint`
- Implement tool execution loop
- Add embedding generation to message flow
- Create backfill script for existing data

### Week 3: Frontend Integration
- Update Flutter client for actions
- Add action dispatcher
- Test end-to-end flows
- UI polish for action feedback

### Week 4: Testing & Optimization
- Performance testing with large datasets
- Vector search accuracy tuning
- User acceptance testing
- Documentation

---

## Success Metrics

### Functional
- ✅ AI can recall past conversations
- ✅ AI can query sleep data
- ✅ AI can trigger app actions
- ✅ Vector search returns relevant results

### Performance
- Embedding generation: < 500ms per text
- Vector search: < 100ms for top 10 results
- End-to-end response time: < 3 seconds

### User Experience
- Conversations feel contextual and personalized
- AI proactively offers helpful insights
- Actions execute smoothly without user friction

---

## Next Immediate Steps

1. **Generate Protocol:**
   ```powershell
   cd insomniabutler_server
   serverpod generate
   ```

2. **Run Migration:**
   ```powershell
   .\run-migrations.ps1
   ```

3. **Test Embedding Service:**
   ```dart
   final embedding = await EmbeddingService(apiKey).generateEmbedding("test");
   print(embedding.length); // Should be 768
   ```

4. **Refactor Endpoint:**
   Start with adding history support, then tools, then embeddings

---

## Future Enhancements

### Advanced Features
- **Proactive Insights:** Daily summary of sleep patterns
- **Trend Detection:** "You've been stressed about work for 3 weeks"
- **Personalized Recommendations:** Based on what worked before
- **Multi-modal Input:** Voice notes, images from journal

### Additional Tools
- `schedule_sleep_session` - Plan bedtime based on patterns
- `analyze_mood_trends` - Correlate mood with sleep quality
- `suggest_journal_prompt` - Personalized prompts based on history
- `export_insights` - Generate PDF reports

### Scalability
- Move to async embedding generation (queue-based)
- Implement embedding cache layer (Redis)
- Add vector search result caching
- Optimize for mobile bandwidth (compress responses)
