import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class DemoScreen extends StatefulWidget {
  final VoidCallback onNext;

  const DemoScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _showFinalCta = false;
  int _sleepReadiness = 45;

  @override
  void initState() {
    super.initState();
    // Start with the initial prompt
    _messages.add({
      'isUser': false,
      'text': "What's worrying you tonight?",
      'type': 'initial',
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate Butler thinking
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'text':
              "I hear you. That sounds exhausting.\n\nFirst - can you do anything about this right now, at 2 AM?",
          'type': 'question',
        });
      });
      _scrollToBottom();
    });
  }

  void _handleOption(String option) {
    setState(() {
      _messages.last['isSelected'] = true; // Mark question as answered
      _messages.add({'isUser': true, 'text': option});
      _isTyping = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _sleepReadiness = 75;
        _showFinalCta = true;
        _messages.add({
          'isUser': false,
          'text':
              "Exactly. Your 2 AM brain is trying to solve a problem your morning-self is better equipped for.\n\nLet's park this thought properly.",
          'type': 'closure',
        });
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Deep Night Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.bgMainGradient,
                ),
              ),
            ),

            // Chat Messages
            SafeArea(
              bottom: false,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 150),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }

                  final msg = _messages[index];
                  if (msg['isUser']) {
                    return _buildUserBubble(msg['text']);
                  } else {
                    return _buildButlerBubble(msg);
                  }
                },
              ),
            ),

            // Bottom Input Area or CTA
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  if (_showFinalCta)
                    _buildFinalCta()
                  else if (_messages.length == 1 && !_isTyping)
                    _buildInputArea()
                  else if (_messages.last['type'] == 'question' &&
                      !_isTyping &&
                      _messages.last['isSelected'] != true)
                    _buildOptionsArea()
                  else
                    const SizedBox(height: 100), // Padding for dots
                  const SizedBox(height: 60), // Space for dots Overlay
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accentPrimary.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: AppColors.accentPrimary.withOpacity(0.3)),
        ),
        child: Text(text, style: AppTextStyles.body),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildButlerBubble(Map<String, dynamic> msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24, right: 40),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.aiBubbleColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: AppColors.surfaceElevated,
                width: 1.5,
              ),
            ),
            child: Text(
              msg['text'],
              style: AppTextStyles.body.copyWith(height: 1.5),
            ),
          ),
          if (msg['type'] == 'closure') _buildSleepStats(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildSleepStats() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24, right: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentSuccess.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentSuccess.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Icon(Icons.bolt, color: AppColors.accentSuccess, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Sleep Readiness increased: 45% → 75%",
              style: AppTextStyles.label.copyWith(
                color: AppColors.accentSuccess,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppColors.accentSuccess,
            size: 18,
          ),
        ],
      ),
    ).animate().scale(delay: 600.ms);
  }

  Widget _buildTypingIndicator() {
    return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.aiBubbleColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder.withOpacity(0.2)),
            ),
            child: Text("...", style: AppTextStyles.labelLg),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1.seconds);
  }

  Widget _buildInputArea() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(
              top: BorderSide(
                color: Color(0x1AFFFFFF),
                width: 0.5,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.glassBorder.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppTextStyles.body,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type your thoughts...",
                      hintStyle: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: _handleSend,
                    icon: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0);
  }

  Widget _buildOptionsArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOptionButton("No", () => _handleOption("No"), true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOptionButton(
              "Yes, but...",
              () => _handleOption("Yes, but..."),
              false,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildOptionButton(String text, VoidCallback onTap, bool primary) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: primary ? AppColors.gradientPrimary : null,
          color: primary ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLg.copyWith(
            color: primary ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFinalCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 20,
      ),
      child: PrimaryButton(
        text: 'I want this',
        onPressed: widget.onNext,
        gradient: AppColors.gradientSuccess,
      ),
    ).animate().fadeIn().scale();
  }
}

/// Onboarding Screen 5: Permissions
class PermissionsScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const PermissionsScreen({
    Key? key,
    required this.onNext,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080D20), // Fallback
      child: Stack(
        children: [
          // Deep Night Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgMainGradient,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(),

                  // Icon/Header Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accentPrimary.withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      size: 64,
                      color: AppColors.accentPrimary,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    'We respect your privacy',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'To help you sleep better, we need your permission to send gentle reminders.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Permission Item
                  _buildPermissionItem(
                        '🔔',
                        'Notifications',
                        'Gentle reminders for your sleep window.',
                        _notificationsEnabled,
                        (value) =>
                            setState(() => _notificationsEnabled = value),
                      )
                      .animate()
                      .slideY(begin: 0.2, end: 0, delay: 600.ms)
                      .fadeIn(),

                  const SizedBox(height: AppSpacing.lg),

                  // Privacy Statement
                  Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            const Text('🔒', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your thoughts are encrypted',
                                    style: AppTextStyles.labelLg.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '✓ You control all data. ✓ No ads.',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .slideY(begin: 0.2, end: 0, delay: 800.ms)
                      .fadeIn(),

                  const Spacer(),

                  // CTA Section
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Grant permissions',
                      onPressed: widget.onNext,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Skip for now',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for indicators
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    String emoji,
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentPrimary,
            activeTrackColor: AppColors.accentPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
