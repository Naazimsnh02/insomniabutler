import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

/// Onboarding Screen 4: Interactive Demo
class DemoScreen extends StatefulWidget {
  final VoidCallback onNext;

  const DemoScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showResponse = false;
  bool _showButtons = false;
  bool _showClosure = false;
  int _sleepReadiness = 45;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSubmit() {
    if (_controller.text.trim().isNotEmpty) {
      FocusScope.of(context).unfocus();
      setState(() {
        _showResponse = true;
      });
      _scrollToBottom();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showButtons = true;
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _onAnswerNo() {
    setState(() {
      _showClosure = true;
      _sleepReadiness = 75;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Try it now',
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // User Input
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's worrying you tonight?",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _controller,
                            style: AppTextStyles.body,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "I'm worried about...",
                              hintStyle: AppTextStyles.body.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                borderSide: BorderSide(color: AppColors.glassBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                borderSide: BorderSide(color: AppColors.glassBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                borderSide: BorderSide(color: AppColors.accentPrimary),
                              ),
                            ),
                            onSubmitted: (_) => _onSubmit(),
                          ),
                          if (!_showResponse) ...[
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                text: 'Submit',
                                onPressed: _onSubmit,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // AI Response
                    if (_showResponse) ...[
                      const SizedBox(height: AppSpacing.lg),
                      GlassCard(
                        elevated: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradientPrimary,
                                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                  ),
                                  child: const Icon(
                                    Icons.psychology,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  'AI Butler',
                                  style: AppTextStyles.labelLg.copyWith(
                                    color: AppColors.accentPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              "Let's work through this together.\n\nFirst - can you do anything about this right now, at 2 AM?",
                              style: AppTextStyles.body,
                            ),
                            if (_showButtons) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _onAnswerNo,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.md,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.gradientPrimary,
                                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                        ),
                                        child: Text(
                                          'No',
                                          style: AppTextStyles.labelLg.copyWith(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _onAnswerNo,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.md,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.glassBg,
                                          border: Border.all(color: AppColors.glassBorder),
                                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                        ),
                                        child: Text(
                                          'Yes, but...',
                                          style: AppTextStyles.labelLg,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    // Closure
                    if (_showClosure) ...[
                      const SizedBox(height: AppSpacing.lg),
                      GlassCard(
                        gradient: AppColors.gradientCalm,
                        child: Column(
                          children: [
                            Text(
                              "Exactly. Your 2 AM brain is trying to solve a problem your morning-self is much better equipped to handle.\n\nLet's park this thought properly.",
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sleep Readiness',
                                    style: AppTextStyles.labelLg.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '45%',
                                        style: AppTextStyles.h4.copyWith(
                                          color: Colors.white.withOpacity(0.6),
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        '75%',
                                        style: AppTextStyles.h4.copyWith(
                                          color: AppColors.accentSuccess,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.accentSuccess,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_showClosure)
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'I want this',
                  onPressed: widget.onNext,
                  gradient: AppColors.gradientSuccess,
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  children: [
                    const Spacer(),
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'We respect your privacy',
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'To help you sleep better, we need:',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Permissions List
                    _buildPermissionItem(
                      '🔔',
                      'Notifications',
                      'Gentle reminders for sleep window',
                      _notificationsEnabled,
                      (value) => setState(() => _notificationsEnabled = value),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Privacy Statement
                    GlassCard(
                      child: Row(
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 32)),
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
                                  '✓ You control all data. ✓ No ads. Ever.',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // CTA Buttons
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
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildPermissionItem(
    String emoji,
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return GlassCard(
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
          ),
        ],
      ),
    );
  }
}
