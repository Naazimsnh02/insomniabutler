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
        backgroundColor: AppColors.bgPrimary,
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
        backgroundColor: AppColors.bgPrimary,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
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
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
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
                    const SizedBox(height: AppSpacing.lg),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 24,
                      color: AppColors.bgSecondary.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (title != null && title.isNotEmpty) ...[
                            Text(
                              title.trim().substring(0, 1).toUpperCase() + title.trim().substring(1),
                              style: AppTextStyles.h2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentPrimary,
                              ),
                            ),
                            const Divider(color: Colors.white10, height: 32),
                          ],
                          Text(
                            content,
                            style: AppTextStyles.body.copyWith(
                              height: 1.8,
                              fontSize: 16,
                              color: AppColors.textPrimary.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
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
          _buildIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () {
              HapticHelper.lightImpact();
              Navigator.pop(context);
            },
          ),
          Row(
            children: [
              _buildIconButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: isFavorite ? AppColors.accentError : Colors.white,
                onTap: _toggleFavorite,
              ),
              const SizedBox(width: 12),
              _buildIconButton(
                icon: Icons.edit_rounded,
                onTap: () async {
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap, Color? iconColor}) {
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
          color: iconColor ?? Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMetadata(DateTime date, String? moodEmoji, String? mood) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          if (moodEmoji != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
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
                    color: AppColors.textPrimary,
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
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: GlassCard(
          onTap: _isDeleting ? null : _deleteEntry,
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: 20,
          color: AppColors.accentError.withOpacity(0.08),
          border: Border.all(
            color: AppColors.accentError.withOpacity(0.2),
            width: 1.5,
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
              const SizedBox(width: 12),
              Text(
                _isDeleting ? 'Deleting...' : 'Delete Entry',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.accentError,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
