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
class ThoughtClearingScreen extends StatefulWidget {
  const ThoughtClearingScreen({Key? key}) : super(key: key);

  @override
  State<ThoughtClearingScreen> createState() => _ThoughtClearingScreenState();
}

class _ThoughtClearingScreenState extends State<ThoughtClearingScreen> with TickerProviderStateMixin {
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
    
    _readinessAnimation = Tween<double>(
      begin: _previousReadiness.toDouble(),
      end: _sleepReadiness.toDouble(),
    ).animate(CurvedAnimation(
      parent: _readinessAnimController,
      curve: Curves.easeOutCubic,
    ));
    
    // Initial AI greeting
    _addMessage(ChatMessage(
      role: 'assistant',
      content: "What's on your mind tonight? I'm here to help you clear your thoughts so you can rest.",
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _readinessAnimController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    
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

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userMessage = _controller.text.trim();
    _controller.clear();
    
    // Light haptic feedback for send action
    await HapticHelper.lightImpact();
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Add user message
    _addMessage(ChatMessage(
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));
    
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
      
      // Add AI response
      _addMessage(ChatMessage(
        role: 'assistant',
        content: response.message,
        timestamp: DateTime.now(),
        category: response.category,
      ));
      
      // Update category if detected
      if (response.category.isNotEmpty && response.category != 'general') {
        setState(() {
          _currentCategory = _getCategoryEmoji(response.category);
        });
      }
      
      // Update readiness with animation
      setState(() {
        _previousReadiness = _sleepReadiness;
        _sleepReadiness = response.newReadiness;
        _isLoading = false;
      });
      
      _readinessAnimation = Tween<double>(
        begin: _previousReadiness.toDouble(),
        end: _sleepReadiness.toDouble(),
      ).animate(CurvedAnimation(
        parent: _readinessAnimController,
        curve: Curves.easeOutCubic,
      ));
      
      _readinessAnimController.forward(from: 0);
      
      // Medium haptic for readiness increase
      await HapticHelper.mediumImpact();
      
      // Show success animation if high readiness
      if (_sleepReadiness >= 75) {
        await HapticHelper.success();
        _showSuccessAnimation();
      }
      
    } on TimeoutException {
      setState(() => _isLoading = false);
      await HapticHelper.error();
      _showError('Request timed out. Please check your connection and try again.');
    } on SocketException {
      setState(() => _isLoading = false);
      await HapticHelper.error();
      _showError('No internet connection. Please check your network.');
    } catch (e) {
      setState(() => _isLoading = false);
      await HapticHelper.error();
      
      // User-friendly error messages
      String errorMessage = 'Unable to process thought. ';
      if (e.toString().contains('User not logged in')) {
        errorMessage += 'Please log in again.';
      } else if (e.toString().contains('Gemini')) {
        errorMessage += 'AI service temporarily unavailable.';
      } else {
        errorMessage += 'Please try again.';
      }
      
      _showError(errorMessage);
      
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

  void _showSuccessAnimation() {
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.accentSuccess),
            SizedBox(width: 12),
            Text('Great progress! You\'re ready for sleep 💤'),
          ],
        ),
        backgroundColor: AppColors.glassBgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentError,
      ),
    );
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
          gradient: AppColors.bgPrimary,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
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
              if (_currentCategory != null) _buildCategoryBadge(),
              _buildReadinessIndicator(),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
          
          const Spacer(),
          
          // Title
          Column(
            children: [
              Text(
                'Thought Clearing',
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
          ).animate().fadeIn(delay: 200.ms),
          
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
          gradient: isUser ? AppColors.gradientPrimary : null,
          color: isUser ? null : AppColors.glassBg,
          border: isUser ? null : Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(AppBorderRadius.xl).copyWith(
            topLeft: isUser ? const Radius.circular(AppBorderRadius.xl) : const Radius.circular(4),
            topRight: isUser ? const Radius.circular(4) : const Radius.circular(AppBorderRadius.xl),
          ),
          boxShadow: isUser ? AppShadows.buttonShadow : null,
        ),
        child: Text(
          message.content,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
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
          color: AppColors.glassBg,
          border: Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
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
    ).animate(onPlay: (controller) => controller.repeat()).fadeIn();
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.accentPrimary,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .fadeIn(delay: (index * 200).ms, duration: 600.ms)
      .then()
      .fadeOut(duration: 600.ms);
  }

  Widget _buildCategoryBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.gradientThought,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentCategory!,
            style: AppTextStyles.bodySm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms);
  }

  Widget _buildReadinessIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep Readiness',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AnimatedBuilder(
                animation: _readinessAnimation,
                builder: (context, child) {
                  final currentValue = _readinessAnimation.value.round();
                  return Text(
                    '$currentValue%',
                    style: AppTextStyles.h3.copyWith(
                      color: _getReadinessColor(currentValue),
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            child: AnimatedBuilder(
              animation: _readinessAnimation,
              builder: (context, child) {
                final currentValue = _readinessAnimation.value;
                return LinearProgressIndicator(
                  value: currentValue / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.glassBg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getReadinessColor(currentValue.round()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      decoration: BoxDecoration(
        color: AppColors.glassBg.withOpacity(0.5),
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerPadding,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassBg,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your thoughts...',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    boxShadow: AppShadows.buttonShadow,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
