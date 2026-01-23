import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:io';
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../models/chat_message.dart';
import '../main.dart';
import '../services/user_service.dart';
import '../utils/haptic_helper.dart';

/// Thought Clearing Chat UI - CORE FEATURE
/// Premium glassmorphic chat interface for processing anxious thoughts
class InsomniaButlerScreen extends StatefulWidget {
  final String? sessionId;

  const InsomniaButlerScreen({super.key, this.sessionId});

  @override
  State<InsomniaButlerScreen> createState() => _InsomniaButlerScreenState();
}

class _InsomniaButlerScreenState extends State<InsomniaButlerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late final String _sessionId;
  bool _isHistoryLoading = false;

  int _sleepReadiness = 45;
  int _previousReadiness = 45;
  bool _isLoading = false;
  String? _currentCategory;

  late AnimationController _readinessAnimController;
  late Animation<double> _readinessAnimation;

  @override
  void initState() {
    super.initState();

    _readinessAnimController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _readinessAnimation =
        Tween<double>(
          begin: _previousReadiness.toDouble(),
          end: _sleepReadiness.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _readinessAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    _sessionId = widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

    if (widget.sessionId != null) {
      _loadSessionHistory();
    } else {
      // Initial AI greeting
      _addMessage(
        ChatMessage(
          role: 'assistant',
          content:
              "What's on your mind tonight? I'm here to help you clear your thoughts so you can rest.",
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _loadSessionHistory() async {
    setState(() => _isHistoryLoading = true);
    try {
      final messages = await client.thoughtClearing.getChatSessionMessages(_sessionId);
      
      // Map Serverpod ChatMessage to our local ChatMessage model
      final mappedMessages = messages.map((m) => ChatMessage(
        role: m.role,
        content: m.content,
        timestamp: m.timestamp,
        category: null, 
      )).toList();

      setState(() {
        _messages.addAll(mappedMessages);
        _isHistoryLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading session history: $e');
      setState(() => _isHistoryLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _readinessAnimController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Auto-scroll to bottom with smooth animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    // Light haptic feedback for send action
    await HapticHelper.lightImpact();

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Add user message
    _addMessage(
      ChatMessage(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ),
    );

    setState(() => _isLoading = true);

    try {
      // Get current user ID
      final userId = await UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Call Serverpod thought clearing endpoint
      final response = await client.thoughtClearing.processThought(
        userId,
        userMessage,
        _sessionId,
        _sleepReadiness,
      );

      // Add AI response and update state in a single call to prevent flickering
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content: response.message,
            timestamp: DateTime.now(),
            category: response.category,
          ),
        );

        if (response.category.isNotEmpty && response.category != 'general') {
          _currentCategory = _getCategoryEmoji(response.category);
        }

        _previousReadiness = _sleepReadiness;
        _sleepReadiness = response.newReadiness;
        _isLoading = false;
      });

      // Auto-scroll to bottom
      _scrollToBottom();

      _readinessAnimation =
          Tween<double>(
            begin: _previousReadiness.toDouble(),
            end: _sleepReadiness.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _readinessAnimController,
              curve: Curves.easeOutCubic,
            ),
          );

      _readinessAnimController.forward(from: 0);

      // Medium haptic for readiness increase
      await HapticHelper.mediumImpact();

      // Show success animation if high readiness
      if (_sleepReadiness >= 75) {
        await HapticHelper.success();
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
    } on SocketException {
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      // Log error for debugging
      print('Thought processing error: $e');
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'work':
        return '💼 Work Anxiety';
      case 'social':
        return '👥 Social Concerns';
      case 'health':
        return '🧘 Health & Wellness';
      case 'planning':
        return '📅 Planning Thoughts';
      case 'financial':
        return '💰 Financial Worries';
      default:
        return '💭 General Thoughts';
    }
  }

  Color _getReadinessColor(int readiness) {
    if (readiness < 50) return AppColors.sleepReadyLow;
    if (readiness < 75) return AppColors.sleepReadyMid;
    return AppColors.sleepReadyHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
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
            bottom: 200,
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

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildInsightsPanel(),
                const SizedBox(height: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.containerPadding,
                        vertical: AppSpacing.md,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isHistoryLoading && index == 0) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: AppColors.accentPrimary),
                            ),
                          );
                        }
                        if (index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        return _buildChatBubble(_messages[index], index);
                      },
                    ),
                  ),
                ),
                _buildInputField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.lg,
        AppSpacing.containerPadding,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _buildIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context, true),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(delay: 100.ms),

          const Spacer(),

          Column(
            children: [
              Text(
                'Insomnia Butler',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accentCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Always here for you',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0),

          const Spacer(),

          _buildIconButton(
                icon: Icons.history_rounded,
                onTap: () async {
                  await HapticHelper.lightImpact();
                  final result = await Navigator.pushNamed(context, '/chat_history');
                  if (result != null && result is String) {
                    if (result == "NEW_SESSION") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InsomniaButlerScreen(),
                        ),
                      );
                    } else if (result != _sessionId) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InsomniaButlerScreen(sessionId: result),
                        ),
                      );
                    }
                  }
                },
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(delay: 150.ms),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, int index) {
    final isUser = message.isUser;

    return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: isUser
                  ? LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.2),
                        AppColors.accentPrimary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUser ? null : AppColors.bgSecondary.withOpacity(0.4),
              border: Border.all(
                color: isUser
                    ? AppColors.accentPrimary.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(24).copyWith(
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(24),
                bottomLeft: isUser
                    ? const Radius.circular(24)
                    : const Radius.circular(4),
              ),
              boxShadow: isUser
                  ? [
                      BoxShadow(
                        color: AppColors.accentPrimary.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              message.content,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textPrimary.withOpacity(0.9),
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
        )
        .animate(key: ValueKey(message.timestamp.millisecondsSinceEpoch))
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withOpacity(0.4),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildDot(int index) {
    return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.accentPrimary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(delay: (index * 200).ms, duration: 600.ms)
        .then()
        .fadeOut(duration: 600.ms);
  }

  Widget _buildInsightsPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 20,
        color: AppColors.bgSecondary.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_rounded,
                size: 14,
                color: AppColors.accentPrimary,
              ),
            ),
            const SizedBox(width: 12),
            if (_currentCategory != null) ...[
              Text(
                _currentCategory!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '|',
                  style: TextStyle(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ],
            AnimatedBuilder(
              animation: _readinessAnimation,
              builder: (context, child) {
                final currentValue = _readinessAnimation.value.round();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sleep Readiness:',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$currentValue%',
                      style: AppTextStyles.caption.copyWith(
                        color: _getReadinessColor(currentValue),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 24,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        borderRadius: 32,
        color: AppColors.bgSecondary.withOpacity(0.6),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Share what\'s on your mind...',
                  hintStyle: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textTertiary.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
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
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
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
}
