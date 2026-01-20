import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import '../../utils/haptic_helper.dart';

/// Journal Editor Screen - Create/Edit journal entries
/// Beautiful glassmorphic editor with mood selection and tags
class JournalEditorScreen extends StatefulWidget {
  final int? entryId; // null for new entry

  const JournalEditorScreen({Key? key, this.entryId}) : super(key: key);

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedMood;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isLoading = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Great'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😔', 'label': 'Low'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😡', 'label': 'Frustrated'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '🥱', 'label': 'Tired'},
  ];

  List<dynamic> _prompts = [];
  bool _showPrompts = true;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadEntry();
    } else {
      _loadPrompts();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEntry() async {
    setState(() => _isLoading = true);

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) return;

      final entry = await client.journal.getEntry(widget.entryId!, userId);
      if (entry != null) {
        setState(() {
          _titleController.text = entry.title ?? '';
          _contentController.text = entry.content;
          _selectedMood = entry.mood;
          _selectedDate = entry.entryDate.toLocal();
          _showPrompts = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading entry: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPrompts() async {
    try {
      final hour = DateTime.now().hour;
      final category = hour < 12
          ? 'morning'
          : hour < 17
          ? 'evening'
          : 'evening';

      final prompts = await client.journal.getDailyPrompts(category);
      setState(() => _prompts = prompts);
    } catch (e) {
      debugPrint('Error loading prompts: $e');
    }
  }

  Future<void> _saveEntry() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before saving'),
          backgroundColor: AppColors.accentError,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await HapticHelper.mediumImpact();

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      if (widget.entryId == null) {
        // Create new entry
        await client.journal.createEntry(
          userId,
          _contentController.text.trim(),
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          mood: _selectedMood,
          isFavorite: false,
          entryDate: _selectedDate.toUtc(),
        );
      } else {
        // Update existing entry
        await client.journal.updateEntry(
          widget.entryId!,
          userId,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: _contentController.text.trim(),
          mood: _selectedMood,
        );
      }

      await HapticHelper.success();
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      await HapticHelper.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: AppColors.accentError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgPrimary),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _buildHeader(),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showPrompts && _prompts.isNotEmpty) ...[
                        _buildPromptsSection(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      _buildDateSelector(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildMoodSelector(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildTitleInput(),
                      const SizedBox(height: AppSpacing.md),
                      _buildContentInput(),
                      const SizedBox(height: 100), // Space for save button
                    ],
                  ),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Text(
            widget.entryId == null ? 'New Entry' : 'Edit Entry',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildPromptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Writing Prompts',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.accentAmber,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                HapticHelper.lightImpact();
                setState(() => _showPrompts = false);
              },
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textTertiary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ..._prompts.take(3).map((prompt) => _buildPromptCard(prompt)),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildPromptCard(dynamic prompt) {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        _contentController.text = prompt.promptText + '\n\n';
        setState(() => _showPrompts = false);
        // Focus on content field
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.accentAmber,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                prompt.promptText,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.accentSkyBlue,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(_selectedDate),
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(_selectedDate),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              HapticHelper.lightImpact();
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.accentPrimary,
                        onSurface: AppColors.textPrimary,
                        surface: AppColors.backgroundDeep,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            icon: const Icon(
              Icons.edit_calendar_rounded,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How are you feeling?', style: AppTextStyles.labelLg),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _moods.map((mood) {
            final isSelected = _selectedMood == mood['label'];
            return GestureDetector(
              onTap: () {
                HapticHelper.lightImpact();
                setState(() => _selectedMood = mood['label']);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.2)
                      : AppColors.glassBg,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary
                        : AppColors.glassBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mood['emoji']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      mood['label']!,
                      style: AppTextStyles.bodySm.copyWith(
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: 'Title (optional)',
        hintStyle: AppTextStyles.h3.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.normal,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: 1,
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      style: AppTextStyles.body.copyWith(height: 1.6),
      decoration: InputDecoration(
        hintText: 'Write your thoughts...',
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textTertiary,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: null,
      minLines: 10,
      autofocus: widget.entryId == null,
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSaveButton() {
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
        child: SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: _isSaving ? 'Saving...' : 'Save Entry',
            onPressed: _isSaving ? null : _saveEntry,
            icon: Icons.check_rounded,
          ),
        ),
      ),
    );
  }
}
