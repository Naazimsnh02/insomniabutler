import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';

class ManualLogScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData; // Pass if editing

  const ManualLogScreen({Key? key, this.initialData}) : super(key: key);

  @override
  State<ManualLogScreen> createState() => _ManualLogScreenState();
}

class _ManualLogScreenState extends State<ManualLogScreen> {
  late DateTime _date;
  late TimeOfDay _bedtime;
  late TimeOfDay _waketime;
  int _quality = 3;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _date = d['sessionDate'] is DateTime ? (d['sessionDate'] as DateTime).toLocal() : d['sessionDate'];
      _bedtime = TimeOfDay.fromDateTime((d['bedTime'] as DateTime).toLocal());
      _waketime = TimeOfDay.fromDateTime((d['wakeTime'] as DateTime).toLocal());
      _quality = d['sleepQuality'] ?? 3;
    } else {
      _date = DateTime.now();
      _bedtime = const TimeOfDay(hour: 23, minute: 0);
      _waketime = const TimeOfDay(hour: 7, minute: 0);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) => _buildPickerTheme(child!),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _selectTime(bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _waketime,
      builder: (context, child) => _buildPickerTheme(child!),
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) _bedtime = picked;
        else _waketime = picked;
      });
    }
  }

  Widget _buildPickerTheme(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentPrimary,
          onSurface: AppColors.textPrimary,
          surface: AppColors.backgroundDeep,
        ),
      ),
      child: child,
    );
  }

  String _calculateDuration() {
    int start = _bedtime.hour * 60 + _bedtime.minute;
    int end = _waketime.hour * 60 + _waketime.minute;
    int diff = end >= start ? end - start : (1440 - start) + end;
    return '${diff ~/ 60}h ${diff % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.initialData != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgPrimary),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(isEdit),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    children: [
                      _buildDatePicker(),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(child: _buildTimePicker('In Bed', _bedtime, () => _selectTime(true))),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildTimePicker('Woke Up', _waketime, () => _selectTime(false))),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDurationInfo(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildQualityPicker(),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(isEdit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isEdit) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(backgroundColor: AppColors.glassBg),
          ),
          Text(isEdit ? 'Edit Session' : 'Log Sleep', style: AppTextStyles.h4),
          if (isEdit)
            IconButton(
              onPressed: () => _showDeleteConfirm(),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentError),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GlassCard(
      onTap: _selectDate,
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: AppColors.accentPrimary),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session Date', style: AppTextStyles.caption),
              Text(DateFormat('EEEE, MMM d, yyyy').format(_date), style: AppTextStyles.bodyLg),
            ],
          ),
          const Spacer(),
          const Icon(Icons.edit_outlined, size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(time.format(context), style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDurationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.accentPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.accentPrimary),
          const SizedBox(width: AppSpacing.md),
          Text('Total Sleep Duration', style: AppTextStyles.body),
          const Spacer(),
          Text(_calculateDuration(), style: AppTextStyles.h4.copyWith(color: AppColors.accentPrimary)),
        ],
      ),
    );
  }

  Widget _buildQualityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sleep Quality', style: AppTextStyles.labelLg),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final val = i + 1;
            final isSelected = _quality == val;
            return GestureDetector(
              onTap: () => setState(() => _quality = val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentPrimary : AppColors.glassBgElevated,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: isSelected ? AppColors.accentPrimary : AppColors.glassBorder),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.accentPrimary.withOpacity(0.3), blurRadius: 10)] : null,
                ),
                child: Center(
                  child: Text('$val', style: AppTextStyles.h3.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary)),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Poor', style: AppTextStyles.caption),
            Text('Excellent', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: PrimaryButton(
        text: _isLoading 
            ? (isEdit ? 'Updating...' : 'Saving...') 
            : (isEdit ? 'Update Session' : 'Save Session'),
        isLoading: _isLoading,
        onPressed: () => _handleSave(isEdit),
      ),
    );
  }

  Future<void> _handleSave(bool isEdit) async {
    setState(() => _isLoading = true);
    HapticHelper.lightImpact();

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Construct DateTime objects
      final bedDateTime = DateTime(
        _date.year, _date.month, _date.day, _bedtime.hour, _bedtime.minute
      );
      
      // Handle overnight wake time
      DateTime wakeDateTime = DateTime(
        _date.year, _date.month, _date.day, _waketime.hour, _waketime.minute
      );
      if (wakeDateTime.isBefore(bedDateTime)) {
        wakeDateTime = wakeDateTime.add(const Duration(days: 1));
      }

      if (isEdit) {
        await client.sleepSession.updateSession(
          widget.initialData!['id'],
          bedDateTime.toUtc(),
          wakeDateTime.toUtc(),
          _quality,
          null, // sleepLatencyMinutes
        );
      } else {
        await client.sleepSession.logManualSession(
          userId,
          bedDateTime.toUtc(),
          wakeDateTime.toUtc(),
          _quality,
        );
      }

      HapticHelper.success();
      if (mounted) {
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      debugPrint('Error saving session: $e');
      HapticHelper.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save session: ${e.toString()}'),
            backgroundColor: AppColors.accentError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceBlueBlack,
        title: const Text('Delete Session?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _handleDelete();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.accentError)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);
    try {
      await client.sleepSession.deleteSession(widget.initialData!['id']);
      HapticHelper.success();
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error deleting session: $e');
      HapticHelper.error();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
