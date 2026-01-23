import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
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
  const InsomniaButlerScreen({Key? key}) : super(key: key);

  @override
  State<InsomniaButlerScreen> createState() => _InsomniaButlerScreenState();
}

class _InsomniaButlerScreenState extends State<InsomniaButlerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgMainGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildInsightsPanel(),
              const SizedBox(height: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerPadding,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Row(
        children: [
          // Back button with glass effect
          _buildIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context, true),
              )
              .animate(key: const ValueKey('chat_back_btn'))
              .fadeIn(duration: 300.ms)
              .scale(delay: 100.ms),

          const Spacer(),

          // Title
          Column(
            children: [
              Text(
                'Insomnia Butler',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Clear your mind',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ).animate(key: const ValueKey('chat_title')).fadeIn(delay: 200.ms),

          const Spacer(),

          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, int index) {
    final isUser = message.isUser;

    return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.accentPrimary.withOpacity(0.15)
                  : AppColors.bgSecondary.withOpacity(0.4),
              border: Border.all(
                color: isUser
                    ? AppColors.accentPrimary.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                width: isUser ? 1.2 : 1.0,
              ),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
                bottomLeft: isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
              ),
              boxShadow: isUser
                  ? [
                      BoxShadow(
                        color: AppColors.accentPrimary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              message.content,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        )
        .animate(key: ValueKey(message.timestamp.millisecondsSinceEpoch))
        .fadeIn(duration: 300.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 300.ms,
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
        vertical: AppSpacing.xs,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 16,
        color: AppColors.bgSecondary.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_rounded,
              size: 14,
              color: AppColors.textTertiary.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Insights',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_currentCategory != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '·',
                  style: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              Text(
                _currentCategory!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '·',
                style: TextStyle(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            AnimatedBuilder(
              animation: _readinessAnimation,
              builder: (context, child) {
                final currentValue = _readinessAnimation.value.round();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🌙',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$currentValue%',
                      style: AppTextStyles.caption.copyWith(
                        color: _getReadinessColor(currentValue),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        borderRadius: 28,
        color: AppColors.bgSecondary.withOpacity(0.5),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your thoughts...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
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
}
