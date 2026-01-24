import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';
import '../sleep_tracking/widgets/history_skeleton.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatSessionInfo> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromCache();
    _loadHistory();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('chat_history_cache');
      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        final history = decoded.map((item) => ChatSessionInfo.fromJson(item)).toList();
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading chat history cache: $e');
    }
  }

  Future<void> _loadHistory() async {
    if (_history.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final history = await client.thoughtClearing.getChatHistory(userId);
      
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = jsonEncode(history.map((h) => h.toJson()).toList());
        prefs.setString('chat_history_cache', jsonStr);
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
            right: -50,
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
            bottom: 100,
            left: -80,
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
                _buildTopBar(),
                Expanded(
                  child: _isLoading && _history.isEmpty
                      ? const HistorySkeleton()
                      : _history.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadHistory,
                              color: AppColors.accentPrimary,
                              backgroundColor: AppColors.bgSecondary,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(
                                  AppSpacing.containerPadding,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: _history.length,
                                itemBuilder: (context, index) =>
                                    _buildHistoryCard(_history[index], index),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticHelper.lightImpact();
          Navigator.pop(context, "NEW_SESSION");
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.lg,
        AppSpacing.containerPadding,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'Conversation History',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Previous thought clearing sessions',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          _buildIconButton(
            icon: Icons.refresh_rounded,
            onTap: _loadHistory,
          ),
        ],
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
        borderRadius: 14,
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a session to clear your mind',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildHistoryCard(ChatSessionInfo session, int index) {
    final dateStr = DateFormat(
      'EEE, MMM d • HH:mm',
    ).format(session.startTime.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        onTap: () async {
          await HapticHelper.lightImpact();
          if (mounted) {
            Navigator.pop(context, session.sessionId);
          }
        },
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        color: AppColors.bgSecondary.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentPrimary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo/butler_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.psychology_rounded,
                    color: AppColors.accentPrimary,
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.lastMessage,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${session.messageCount}',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  Text(
                    'MSGS',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 22,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }
}
