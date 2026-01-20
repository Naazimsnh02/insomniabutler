import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import '../../utils/haptic_helper.dart';
import 'journal_editor_screen.dart';

/// Journal Detail Screen - View and manage individual journal entry
class JournalDetailScreen extends StatefulWidget {
  final int entryId;

  const JournalDetailScreen({Key? key, required this.entryId})
    : super(key: key);

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  dynamic _entry;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    setState(() => _isLoading = true);

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      final entry = await client.journal.getEntry(widget.entryId, userId);
      setState(() {
        _entry = entry;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading entry: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    await HapticHelper.mediumImpact();

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      final updated = await client.journal.toggleFavorite(
        widget.entryId,
        userId,
      );
      if (updated != null) {
        setState(() => _entry = updated);
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> _deleteEntry() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDeep,
        title: Text('Delete Entry?', style: AppTextStyles.h3),
        content: Text(
          'This action cannot be undone.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.accentError,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    await HapticHelper.error();

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      final success = await client.journal.deleteEntry(widget.entryId, userId);
      if (success && mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting entry: $e'),
            backgroundColor: AppColors.accentError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _entry == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.bgPrimary),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accentPrimary),
          ),
        ),
      );
    }

    final mood = _entry.mood as String?;
    final moodEmoji = _getMoodEmoji(mood);
    final date = (_entry.entryDate as DateTime).toLocal();
    final title = _entry.title as String?;
    final content = _entry.content as String;
    final isFavorite = _entry.isFavorite as bool;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgPrimary),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _buildHeader(isFavorite),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetadata(date, moodEmoji, mood),
                    const SizedBox(height: AppSpacing.xl),
                    if (title != null && title.isNotEmpty) ...[
                      Text(
                        title,
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(
                      content,
                      style: AppTextStyles.body.copyWith(
                        height: 1.8,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isFavorite) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticHelper.lightImpact();
              Navigator.pop(context);
            },
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
          Row(
            children: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.accentError : Colors.white,
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.glassBgElevated,
                  padding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  HapticHelper.lightImpact();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          JournalEditorScreen(entryId: widget.entryId),
                    ),
                  );
                  _loadEntry(); // Refresh after edit
                },
                icon: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.glassBgElevated,
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(DateTime date, String? moodEmoji, String? mood) {
    return GlassCard(
      child: Row(
        children: [
          if (moodEmoji != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
              ),
              child: Text(moodEmoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(date),
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat('h:mm a').format(date),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (mood != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mood,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep.withOpacity(0.8),
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _isDeleting ? null : _deleteEntry,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.accentError.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.accentError.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isDeleting
                      ? Icons.hourglass_empty
                      : Icons.delete_outline_rounded,
                  color: AppColors.accentError,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isDeleting ? 'Deleting...' : 'Delete Entry',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.accentError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _getMoodEmoji(String? mood) {
    if (mood == null) return null;
    final moodMap = {
      'Great': '😊',
      'Good': '🙂',
      'Okay': '😐',
      'Low': '😔',
      'Sad': '😢',
      'Anxious': '😰',
      'Frustrated': '😡',
      'Calm': '😌',
      'Tired': '🥱',
    };
    return moodMap[mood];
  }
}
