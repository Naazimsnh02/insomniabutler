# 🚀 Insomnia Butler - AI Implementation Task Plan

**Project:** AI-powered sleep companion with thought clearing and pattern intelligence  
**Stack:** Flutter + Serverpod 3 + Gemini AI + PostgreSQL  
**Timeline:** 4 Days (Hackathon Sprint)

---

## 📋 Implementation Phases Overview

```
Phase 1: Foundation & Setup (Day 1)
Phase 2: Backend Core (Day 1-2)
Phase 3: Frontend Core (Day 2-3)
Phase 4: Intelligence & Analytics (Day 3)
Phase 5: Polish & Demo Prep (Day 3-4)
```

---

# PHASE 1: FOUNDATION & SETUP

## Task 1.1: Project Initialization
**Priority:** CRITICAL | **Time:** 30 min | **AI Difficulty:** Easy

### Objectives:
- Initialize Serverpod 3 project structure
- Set up Flutter client project
- Configure PostgreSQL database
- Verify development environment

### Steps:
1. Run `serverpod create insomnia_butler`
2. Initialize Flutter app in `insomnia_butler_flutter`
3. Configure `config/development.yaml` with database credentials
4. Test server startup: `dart bin/main.dart`
5. Verify database connection

### Success Criteria:
- ✅ Server runs on localhost:8080
- ✅ Flutter app builds successfully
- ✅ Database migrations run without errors

---

## Task 1.2: Database Schema Design
**Priority:** CRITICAL | **Time:** 45 min | **AI Difficulty:** Medium

### Objectives:
- Create Serverpod protocol models
- Define database relationships
- Generate migrations

### Models to Create:

**1. User Model** (`lib/src/protocol/user.yaml`)
```yaml
class: User
table: users
fields:
  email: String
  name: String
  sleepGoal: String?
  bedtimePreference: DateTime?
  createdAt: DateTime
```

**2. SleepSession Model** (`lib/src/protocol/sleep_session.yaml`)
```yaml
class: SleepSession
table: sleep_sessions
fields:
  userId: int
  bedTime: DateTime
  wakeTime: DateTime?
  sleepLatencyMinutes: int?
  usedButler: bool
  thoughtsProcessed: int
  sleepQuality: int?
  morningMood: String?
  sessionDate: DateTime
```

**3. ThoughtLog Model** (`lib/src/protocol/thought_log.yaml`)
```yaml
class: ThoughtLog
table: thought_logs
fields:
  userId: int
  sessionId: int?
  category: String
  content: String
  timestamp: DateTime
  resolved: bool
  readinessIncrease: int
```

**4. ChatMessage Model** (`lib/src/protocol/chat_message.yaml`)
```yaml
class: ChatMessage
table: chat_messages
fields:
  sessionId: String
  userId: int
  role: String
  content: String
  timestamp: DateTime
```

**5. SleepInsight Model** (`lib/src/protocol/sleep_insight.yaml`)
```yaml
class: SleepInsight
table: sleep_insights
fields:
  userId: int
  insightType: String
  metric: String
  value: double
  description: String
  generatedAt: DateTime
```

### Steps:
1. Create all 5 YAML model files
2. Run `serverpod generate`
3. Run database migrations
4. Verify tables created in PostgreSQL

### Success Criteria:
- ✅ All models generated without errors
- ✅ Database tables exist with correct schema
- ✅ Foreign key relationships established

---

## Task 1.3: Gemini API Integration Setup
**Priority:** CRITICAL | **Time:** 30 min | **AI Difficulty:** Easy

### Objectives:
- Add Google Generative AI package
- Create Gemini service wrapper
- Test API connectivity

### Steps:
1. Add to `pubspec.yaml`:
```yaml
dependencies:
  google_generative_ai: ^0.2.0
```

2. Create `lib/src/services/gemini_service.dart`:
```dart
class GeminiService {
  final GenerativeModel model;
  
  GeminiService(String apiKey) : model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  
  Future<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final prompt = '$systemPrompt\n\nUser: $userMessage';
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}
```

3. Add API key to `config/development.yaml`
4. Test with simple prompt

### Success Criteria:
- ✅ Gemini responds to test prompts
- ✅ Error handling works
- ✅ API key securely stored

---

# PHASE 2: BACKEND CORE

## Task 2.1: Authentication Endpoint
**Priority:** HIGH | **Time:** 45 min | **AI Difficulty:** Medium

### Objectives:
- Implement user registration
- Implement login
- Session management

### Create: `lib/src/endpoints/auth_endpoint.dart`

```dart
class AuthEndpoint extends Endpoint {
  Future<User?> register(Session session, String email, String name) async {
    // Check if user exists
    var existing = await User.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );
    
    if (existing != null) return null;
    
    // Create user
    var user = User(
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    
    return await User.db.insertRow(session, user);
  }
  
  Future<User?> login(Session session, String email) async {
    return await User.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );
  }
}
```

### Success Criteria:
- ✅ Users can register
- ✅ Users can login
- ✅ Duplicate emails rejected

---

## Task 2.2: Thought Clearing Endpoint (CORE FEATURE)
**Priority:** CRITICAL | **Time:** 2 hours | **AI Difficulty:** Hard

### Objectives:
- Process user thoughts through Gemini
- Categorize thoughts
- Calculate sleep readiness
- Store conversation history

### Create: `lib/src/endpoints/thought_clearing_endpoint.dart`

```dart
class ThoughtClearingEndpoint extends Endpoint {
  final GeminiService _gemini = GeminiService(/* API key */);
  
  Future<ThoughtResponse> processThought(
    Session session,
    String userMessage,
    String sessionId,
    int currentReadiness,
  ) async {
    // Build CBT-I system prompt
    final systemPrompt = _buildSystemPrompt(currentReadiness);
    
    // Get AI response
    final aiResponse = await _gemini.sendMessage(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
    );
    
    // Extract category from response
    final category = _extractCategory(aiResponse);
    
    // Calculate readiness increase
    final readinessIncrease = _calculateReadinessIncrease(category);
    
    // Save user message
    await ChatMessage.db.insertRow(session, ChatMessage(
      sessionId: sessionId,
      userId: session.auth!.userId,
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));
    
    // Save AI response
    await ChatMessage.db.insertRow(session, ChatMessage(
      sessionId: sessionId,
      userId: session.auth!.userId,
      role: 'assistant',
      content: aiResponse,
      timestamp: DateTime.now(),
    ));
    
    // Log thought
    await ThoughtLog.db.insertRow(session, ThoughtLog(
      userId: session.auth!.userId,
      category: category,
      content: userMessage,
      timestamp: DateTime.now(),
      resolved: false,
      readinessIncrease: readinessIncrease,
    ));
    
    return ThoughtResponse(
      message: aiResponse,
      category: category,
      newReadiness: currentReadiness + readinessIncrease,
    );
  }
  
  String _buildSystemPrompt(int currentReadiness) {
    return '''
You are Insomnia Butler, an AI sleep coach trained in CBT-I (Cognitive Behavioral Therapy for Insomnia).

Your goal: Help users clear their racing thoughts so they can sleep.

RULES:
1. Be warm but concise (this is 2 AM, they're tired)
2. Use the Socratic method - guide, don't lecture
3. Always ask: "Can you solve this right now?"
4. Help them create tomorrow-actions for tonight-worries
5. End with a closure statement
6. NEVER provide medical advice
7. If detecting crisis language → provide helpline resources

Current sleep readiness: $currentReadiness%

Respond in a caring, conversational tone. Keep responses under 100 words.
''';
  }
  
  String _extractCategory(String response) {
    // Simple keyword matching (can be enhanced)
    final lower = response.toLowerCase();
    if (lower.contains('work') || lower.contains('job')) return 'work';
    if (lower.contains('relationship') || lower.contains('social')) return 'social';
    if (lower.contains('health') || lower.contains('anxiety')) return 'health';
    if (lower.contains('future') || lower.contains('tomorrow')) return 'planning';
    return 'general';
  }
  
  int _calculateReadinessIncrease(String category) {
    // Base increase on category
    switch (category) {
      case 'work': return 15;
      case 'social': return 12;
      case 'health': return 10;
      case 'planning': return 18;
      default: return 10;
    }
  }
}
```

### Success Criteria:
- ✅ AI responds appropriately to thoughts
- ✅ Categories detected correctly
- ✅ Readiness score increases
- ✅ Conversation history saved

---

## Task 2.3: Sleep Session Endpoint
**Priority:** HIGH | **Time:** 1 hour | **AI Difficulty:** Medium

### Objectives:
- Start sleep session
- End sleep session
- Log sleep data
- Calculate metrics

### Create: `lib/src/endpoints/sleep_session_endpoint.dart`

```dart
class SleepSessionEndpoint extends Endpoint {
  Future<SleepSession> startSession(Session session) async {
    final sleepSession = SleepSession(
      userId: session.auth!.userId,
      bedTime: DateTime.now(),
      usedButler: false,
      thoughtsProcessed: 0,
      sessionDate: DateTime.now(),
    );
    
    return await SleepSession.db.insertRow(session, sleepSession);
  }
  
  Future<SleepSession> endSession(
    Session session,
    int sessionId,
    int sleepQuality,
    String morningMood,
  ) async {
    final sleepSession = await SleepSession.db.findById(session, sessionId);
    
    if (sleepSession == null) throw Exception('Session not found');
    
    final wakeTime = DateTime.now();
    final duration = wakeTime.difference(sleepSession.bedTime);
    
    final updated = sleepSession.copyWith(
      wakeTime: wakeTime,
      sleepQuality: sleepQuality,
      morningMood: morningMood,
    );
    
    return await SleepSession.db.updateRow(session, updated);
  }
  
  Future<void> markButlerUsed(Session session, int sessionId, int thoughtCount) async {
    final sleepSession = await SleepSession.db.findById(session, sessionId);
    
    if (sleepSession != null) {
      await SleepSession.db.updateRow(
        session,
        sleepSession.copyWith(
          usedButler: true,
          thoughtsProcessed: thoughtCount,
        ),
      );
    }
  }
  
  Future<List<SleepSession>> getUserSessions(Session session, int limit) async {
    return await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(session.auth!.userId),
      orderBy: (t) => t.sessionDate,
      orderDescending: true,
      limit: limit,
    );
  }
}
```

### Success Criteria:
- ✅ Sessions can be started/ended
- ✅ Butler usage tracked
- ✅ Session history retrievable

---

## Task 2.4: Analytics & Insights Endpoint
**Priority:** MEDIUM | **Time:** 1.5 hours | **AI Difficulty:** Medium

### Objectives:
- Calculate sleep latency improvements
- Identify thought patterns
- Generate insights

### Create: `lib/src/endpoints/insights_endpoint.dart`

```dart
class InsightsEndpoint extends Endpoint {
  Future<UserInsights> getUserInsights(Session session) async {
    final userId = session.auth!.userId;
    
    // Get sessions with and without Butler
    final withButler = await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.usedButler.equals(true),
    );
    
    final withoutButler = await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.usedButler.equals(false),
    );
    
    // Calculate average latencies
    final avgWithButler = _calculateAvgLatency(withButler);
    final avgWithoutButler = _calculateAvgLatency(withoutButler);
    
    final improvement = avgWithoutButler > 0
        ? ((avgWithoutButler - avgWithButler) / avgWithoutButler * 100).round()
        : 0;
    
    // Get thought patterns
    final thoughts = await ThoughtLog.db.find(
      session,
      where: (t) => t.userId.equals(userId),
    );
    
    final categoryCount = <String, int>{};
    for (var thought in thoughts) {
      categoryCount[thought.category] = (categoryCount[thought.category] ?? 0) + 1;
    }
    
    final topCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return UserInsights(
      latencyImprovement: improvement,
      avgLatencyWithButler: avgWithButler,
      avgLatencyWithoutButler: avgWithoutButler,
      topThoughtCategories: topCategories.take(3).map((e) => e.key).toList(),
      totalThoughtsProcessed: thoughts.length,
      totalSessions: withButler.length + withoutButler.length,
    );
  }
  
  double _calculateAvgLatency(List<SleepSession> sessions) {
    if (sessions.isEmpty) return 0;
    
    final validSessions = sessions.where((s) => s.sleepLatencyMinutes != null);
    if (validSessions.isEmpty) return 0;
    
    final total = validSessions.fold<int>(
      0,
      (sum, s) => sum + (s.sleepLatencyMinutes ?? 0),
    );
    
    return total / validSessions.length;
  }
}
```

### Success Criteria:
- ✅ Improvement percentage calculated
- ✅ Top thought categories identified
- ✅ Insights returned correctly

---

# PHASE 3: FRONTEND CORE

## Task 3.1: Design System Setup
**Priority:** HIGH | **Time:** 1 hour | **AI Difficulty:** Easy

### Objectives:
- Create color constants
- Define text styles
- Build reusable components

### Create: `lib/theme/app_theme.dart`

```dart
class AppColors {
  // Backgrounds
  static const bgPrimary = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF1A1E3E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Accents
  static const accentPrimary = Color(0xFFA78BFA);
  static const accentSecondary = Color(0xFFC084FC);
  static const accentTertiary = Color(0xFF60A5FA);
  static const accentSuccess = Color(0xFF34D399);
  
  // Glass
  static const glassBg = Color(0x14FFFFFF);
  static const glassBorder = Color(0x1FFFFFFF);
  
  // Text
  static const textPrimary = Color(0xF2FFFFFF);
  static const textSecondary = Color(0xA6FFFFFF);
  static const textTertiary = Color(0x73FFFFFF);
}

class AppTextStyles {
  static const displayLg = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.96,
    height: 1.17,
  );
  
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
    height: 1.25,
  );
  
  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.28,
    height: 1.29,
  );
  
  static const bodyLg = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.56,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
```

### Create: `lib/widgets/glass_card.dart`

```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool elevated;
  
  const GlassCard({
    required this.child,
    this.padding,
    this.borderRadius,
    this.elevated = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: elevated ? Color(0x1FFFFFFF) : AppColors.glassBg,
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: child,
      ),
    );
  }
}
```

### Success Criteria:
- ✅ Theme applied globally
- ✅ GlassCard renders correctly
- ✅ Colors match design spec

---

## Task 3.2: Onboarding Flow
**Priority:** MEDIUM | **Time:** 2 hours | **AI Difficulty:** Medium

### Objectives:
- Create 6 onboarding screens
- Add page transitions
- Implement skip/next navigation

### Screens to Create:
1. Splash Screen
2. Welcome Screen ("It's 2 AM")
3. Problem Screen ("You've tried everything")
4. Solution Screen ("Meet Your Butler")
5. Demo Screen (Interactive)
6. Permissions Screen

### Create: `lib/screens/onboarding/onboarding_screen.dart`

```dart
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgPrimary),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) => setState(() => _currentPage = index),
          children: [
            WelcomeScreen(),
            ProblemScreen(),
            SolutionScreen(),
            DemoScreen(),
            PermissionsScreen(),
            SetupScreen(),
          ],
        ),
      ),
    );
  }
}
```

### Success Criteria:
- ✅ All 6 screens implemented
- ✅ Smooth page transitions
- ✅ Can skip to main app

---

## Task 3.3: Thought Clearing Chat UI (CORE FEATURE)
**Priority:** CRITICAL | **Time:** 3 hours | **AI Difficulty:** Hard

### Objectives:
- Build chat interface
- Connect to backend
- Show sleep readiness meter
- Display thought categories

### Create: `lib/screens/thought_clearing_screen.dart`

```dart
class ThoughtClearingScreen extends StatefulWidget {
  @override
  _ThoughtClearingScreenState createState() => _ThoughtClearingScreenState();
}

class _ThoughtClearingScreenState extends State<ThoughtClearingScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final String _sessionId = Uuid().v4();
  int _sleepReadiness = 45;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _addMessage(ChatMessage(
      role: 'assistant',
      content: "What's on your mind tonight?",
      timestamp: DateTime.now(),
    ));
  }
  
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userMessage = _controller.text.trim();
    _controller.clear();
    
    _addMessage(ChatMessage(
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));
    
    setState(() => _isLoading = true);
    
    try {
      final client = Client('http://localhost:8080/');
      final response = await client.thoughtClearing.processThought(
        userMessage,
        _sessionId,
        _sleepReadiness,
      );
      
      _addMessage(ChatMessage(
        role: 'assistant',
        content: response.message,
        timestamp: DateTime.now(),
      ));
      
      setState(() {
        _sleepReadiness = response.newReadiness;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }
  
  void _addMessage(ChatMessage message) {
    setState(() => _messages.add(message));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgPrimary),
        child: SafeArea(
          child: Column(
            children: [
              // Header with readiness
              _buildHeader(),
              
              // Chat messages
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildChatBubble(_messages[index]);
                  },
                ),
              ),
              
              // Loading indicator
              if (_isLoading) _buildTypingIndicator(),
              
              // Input field
              _buildInputField(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'Sleep Ready',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '$_sleepReadiness%',
                style: AppTextStyles.h2.copyWith(
                  color: _sleepReadiness > 75
                      ? AppColors.accentSuccess
                      : AppColors.accentPrimary,
                ),
              ),
            ],
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(colors: [AppColors.accentPrimary, AppColors.accentSecondary])
              : null,
          color: isUser ? null : AppColors.glassBg,
          border: isUser ? null : Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(20).copyWith(
            topLeft: isUser ? Radius.circular(20) : Radius.circular(4),
            topRight: isUser ? Radius.circular(4) : Radius.circular(20),
          ),
        ),
        child: Text(
          message.content,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              SizedBox(width: 4),
              _buildDot(1),
              SizedBox(width: 4),
              _buildDot(2),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1.0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: _controller,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type your thoughts...',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accentPrimary, AppColors.accentSecondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Success Criteria:
- ✅ Messages send/receive correctly
- ✅ Readiness updates in real-time
- ✅ Chat bubbles styled per design
- ✅ Typing indicator animates

---

## Task 3.4: Home Dashboard
**Priority:** HIGH | **Time:** 2 hours | **AI Difficulty:** Medium

### Objectives:
- Display sleep window
- Show quick actions
- Display streak/stats
- Bottom navigation

### Create: `lib/screens/home_screen.dart`

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgPrimary),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 32),
                _buildTonightCard(),
                SizedBox(height: 24),
                _buildQuickActions(context),
                SizedBox(height: 24),
                _buildImpactCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Evening',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 4),
        Text(
          'Ready for bed in 2h 15m',
          style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
  
  Widget _buildTonightCard() {
    return GlassCard(
      elevated: true,
      child: Column(
        children: [
          Text(
            'Tonight\'s Sleep Window',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          Text(
            '11:00 PM - 7:00 AM',
            style: AppTextStyles.displayLg.copyWith(
              color: AppColors.accentPrimary,
              fontSize: 36,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text('Start Wind-Down', style: AppTextStyles.bodyLg),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          _buildActionButton('🧘 Clear Thoughts', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ThoughtClearingScreen()),
            );
          }),
          SizedBox(height: 12),
          _buildActionButton('📊 Last Night', () {}),
          SizedBox(height: 12),
          _buildActionButton('📈 Weekly Insights', () {}),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimary),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImpactCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Impact',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('🔥', '5 Day Streak'),
              _buildStat('📉', '35% Faster Sleep'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStat(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 32)),
        SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
  
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.chat_bubble_outline, 'Butler', false),
          _buildNavItem(Icons.bar_chart, 'Stats', false),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? AppColors.accentPrimary : AppColors.textSecondary,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            color: active ? AppColors.accentPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

### Success Criteria:
- ✅ Dashboard displays correctly
- ✅ Navigation to thought clearing works
- ✅ Bottom nav functional

---

## Task 3.5: Insights Dashboard
**Priority:** MEDIUM | **Time:** 2 hours | **AI Difficulty:** Medium

### Objectives:
- Display improvement stats
- Show thought pattern charts
- Weekly trends

### Create: `lib/screens/insights_screen.dart`

```dart
class InsightsScreen extends StatefulWidget {
  @override
  _InsightsScreenState createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  UserInsights? _insights;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadInsights();
  }
  
  Future<void> _loadInsights() async {
    try {
      final client = Client('http://localhost:8080/');
      final insights = await client.insights.getUserInsights();
      setState(() {
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgPrimary),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Sleep Intelligence',
                  style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 24),
                _buildImpactCard(),
                SizedBox(height: 24),
                _buildThoughtPatternsCard(),
                SizedBox(height: 24),
                _buildStatsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImpactCard() {
    return GlassCard(
      elevated: true,
      child: Column(
        children: [
          Text(
            'This Week\'s Impact',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentPrimary, AppColors.accentSecondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'You fall asleep',
                  style: AppTextStyles.bodyLg.copyWith(color: Colors.white),
                ),
                Text(
                  '${_insights?.latencyImprovement ?? 0}% faster',
                  style: AppTextStyles.displayLg.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
                Text(
                  'after Butler sessions',
                  style: AppTextStyles.bodyLg.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                'With Butler',
                '${_insights?.avgLatencyWithButler?.toInt() ?? 0} min',
              ),
              _buildMetric(
                'Without',
                '${_insights?.avgLatencyWithoutButler?.toInt() ?? 0} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(color: AppColors.accentSuccess),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
  
  Widget _buildThoughtPatternsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thought Patterns',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          ...(_insights?.topThoughtCategories ?? []).map((category) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _getCategoryIcon(category),
                  SizedBox(width: 12),
                  Text(
                    _formatCategory(category),
                    style: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Stats',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          _buildStatRow('Total Sessions', '${_insights?.totalSessions ?? 0}'),
          SizedBox(height: 12),
          _buildStatRow('Thoughts Processed', '${_insights?.totalThoughtsProcessed ?? 0}'),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
  
  String _getCategoryIcon(String category) {
    switch (category) {
      case 'work': return '💼';
      case 'social': return '👥';
      case 'health': return '🧘';
      case 'planning': return '📅';
      default: return '💭';
    }
  }
  
  String _formatCategory(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }
}
```

### Success Criteria:
- ✅ Insights load from backend
- ✅ Stats display correctly
- ✅ Charts render properly

---

# PHASE 4: POLISH & DEMO PREP

## Task 4.1: Demo Data Seeding
**Priority:** HIGH | **Time:** 1 hour | **AI Difficulty:** Easy

### Objectives:
- Create realistic demo data
- Seed 7 days of sessions
- Pre-populate insights

### Create: `lib/src/scripts/seed_demo_data.dart`

```dart
Future<void> seedDemoData(Session session, int userId) async {
  final now = DateTime.now();
  
  // Create 7 days of sleep sessions
  for (int i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final usedButler = i % 2 == 0; // Alternate days
    
    await SleepSession.db.insertRow(session, SleepSession(
      userId: userId,
      bedTime: DateTime(date.year, date.month, date.day, 23, 0),
      wakeTime: DateTime(date.year, date.month, date.day + 1, 7, 0),
      sleepLatencyMinutes: usedButler ? 12 : 28,
      usedButler: usedButler,
      thoughtsProcessed: usedButler ? 3 : 0,
      sleepQuality: usedButler ? 4 : 3,
      morningMood: usedButler ? 'energized' : 'tired',
      sessionDate: date,
    ));
  }
  
  // Create thought logs
  final categories = ['work', 'social', 'health', 'planning'];
  for (int i = 0; i < 20; i++) {
    await ThoughtLog.db.insertRow(session, ThoughtLog(
      userId: userId,
      category: categories[i % categories.length],
      content: 'Demo thought $i',
      timestamp: now.subtract(Duration(days: i ~/ 3)),
      resolved: true,
      readinessIncrease: 15,
    ));
  }
}
```

### Success Criteria:
- ✅ Demo data creates successfully
- ✅ Insights calculate correctly
- ✅ Dashboard shows realistic data

---

## Task 4.2: Error Handling & Offline Mode
**Priority:** MEDIUM | **Time:** 1 hour | **AI Difficulty:** Medium

### Objectives:
- Handle API failures gracefully
- Show error messages
- Offline fallback responses

### Implementation:
- Add try-catch blocks
- Show SnackBar for errors
- Cache last successful data
- Fallback AI responses

### Success Criteria:
- ✅ App doesn't crash on errors
- ✅ User sees helpful error messages
- ✅ Offline mode works for demo

---

## Task 4.3: Animations & Micro-interactions
**Priority:** LOW | **Time:** 1.5 hours | **AI Difficulty:** Medium

### Objectives:
- Add button press animations
- Readiness meter count-up
- Page transitions
- Confetti on high readiness

### Animations to Add:
1. Button scale on press (0.95)
2. Sleep readiness count-up animation
3. Chat bubble fade-in
4. Page slide transitions
5. Confetti when readiness > 75%

### Success Criteria:
- ✅ Animations smooth (60fps)
- ✅ Interactions feel premium
- ✅ No jank or lag

---

## Task 4.4: Demo Video Recording
**Priority:** CRITICAL | **Time:** 1 hour | **AI Difficulty:** Easy

### Objectives:
- Record 2-minute demo video
- Show complete user flow
- Highlight key features

### Demo Script:
1. Open app (0:00-0:05)
2. Show onboarding (0:05-0:20)
3. Navigate to thought clearing (0:20-0:25)
4. Type worry, show AI response (0:25-1:00)
5. Show readiness increase (1:00-1:10)
6. Navigate to insights (1:10-1:30)
7. Show improvement stats (1:30-1:50)
8. End on dashboard (1:50-2:00)

### Success Criteria:
- ✅ Video under 2 minutes
- ✅ Shows all core features
- ✅ No bugs visible
- ✅ Smooth transitions

---

# TESTING CHECKLIST

## Backend Tests
- [ ] User registration/login works
- [ ] Thought processing returns valid responses
- [ ] Sleep sessions save correctly
- [ ] Insights calculate accurately
- [ ] Database migrations run cleanly

## Frontend Tests
- [ ] Onboarding flow completes
- [ ] Chat sends/receives messages
- [ ] Readiness updates in real-time
- [ ] Dashboard loads data
- [ ] Insights display correctly
- [ ] Navigation works smoothly

## Integration Tests
- [ ] End-to-end thought clearing flow
- [ ] Data persists across sessions
- [ ] Offline mode works
- [ ] Error handling graceful

## Demo Readiness
- [ ] Demo data seeded
- [ ] Video recorded
- [ ] Pitch practiced
- [ ] Backup slides ready
- [ ] Offline mode tested

---

# DEPLOYMENT PLAN

## Local Development
1. Run PostgreSQL: `docker run -p 5432:5432 postgres`
2. Start Serverpod: `cd insomnia_butler_server && dart bin/main.dart`
3. Run Flutter: `cd insomnia_butler_flutter && flutter run`

## Demo Day Setup
1. Ensure stable internet
2. Have offline mode ready
3. Pre-load demo data
4. Test on physical device
5. Have video backup ready

---

# SUCCESS METRICS

## Technical Excellence
- ✅ Uses 5+ Serverpod features
- ✅ AI integration with safety
- ✅ Real analytics pipeline
- ✅ Clean architecture

## User Experience
- ✅ Intuitive onboarding
- ✅ Smooth interactions
- ✅ Beautiful glassmorphic UI
- ✅ Meaningful insights

## Demo Impact
- ✅ Clear problem statement
- ✅ Novel solution approach
- ✅ Measurable outcomes
- ✅ Production-ready feel

---

# RISK MITIGATION

| Risk | Mitigation |
|------|------------|
| Gemini API fails | Fallback responses |
| Database issues | SQLite backup |
| Time overrun | Cut app blocking feature |
| Demo bugs | Pre-recorded video |
| Network issues | Offline mode |

---

# FINAL NOTES

**Priority Order:**
1. Thought clearing (core feature)
2. Sleep session logging
3. Basic insights
4. Dashboard UI
5. Onboarding
6. Advanced analytics
7. App blocking (cut if needed)

**Time Allocation:**
- Day 1: Backend + Database (6 hours)
- Day 2: Core UI + Chat (8 hours)
- Day 3: Insights + Polish (8 hours)
- Day 4: Demo prep + Testing (6 hours)

**Remember:**
- Focus on ONE thing done perfectly
- Demo-ready > Feature-complete
- Show impact with data
- Practice pitch 5+ times

---

**This plan is designed for AI-assisted implementation. Each task has clear objectives, code examples, and success criteria. Follow sequentially for best results. Good luck! 💤✨**
