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

  // Advanced Metrics State
  bool _showAdvanced = false;
  int? _deepSleep;
  int? _lightSleep;
  int? _remSleep;
  int? _awake;
  int? _hrv;
  int? _rhr;
  int? _respiratoryRate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _date = d['sessionDate'] is DateTime
          ? (d['sessionDate'] as DateTime).toLocal()
          : d['sessionDate'];
      _bedtime = TimeOfDay.fromDateTime((d['bedTime'] as DateTime).toLocal());
      _waketime = TimeOfDay.fromDateTime((d['wakeTime'] as DateTime).toLocal());
      _quality = d['sleepQuality'] ?? 3;
    } else {
      _date = DateTime.now();
      _bedtime = const TimeOfDay(hour: 23, minute: 0);
      _waketime = const TimeOfDay(hour: 7, minute: 0);
    }

    if (widget.initialData != null) {
      final d = widget.initialData!;
      _deepSleep = d['deepSleepDuration'];
      _lightSleep = d['lightSleepDuration'];
      _remSleep = d['remSleepDuration'];
      _awake = d['awakeDuration'];
      _hrv = d['hrv'];
      _rhr = d['restingHeartRate'];
      _respiratoryRate = d['respiratoryRate'];
      if (_deepSleep != null || 
          _lightSleep != null || 
          _remSleep != null || 
          _awake != null || 
          _hrv != null || 
          _rhr != null || 
          _respiratoryRate != null) {
        _showAdvanced = true;
      }
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
        if (isBedtime)
          _bedtime = picked;
        else
          _waketime = picked;
      });
    }
  }

  Widget _buildPickerTheme(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentPrimary,
          onSurface: AppColors.textPrimary,
          surface: AppColors.bgPrimary,
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
        decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
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
                          Expanded(
                            child: _buildTimePicker(
                              'In Bed',
                              _bedtime,
                              () => _selectTime(true),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildTimePicker(
                              'Woke Up',
                              _waketime,
                              () => _selectTime(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDurationInfo(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildQualityPicker(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildAdvancedSection(),
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
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Text(
            isEdit ? 'Edit Session' : 'Manual Log',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (isEdit)
            _buildIconButton(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.accentError,
              onTap: () => _showDeleteConfirm(),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
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
          color: iconColor ?? Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GlassCard(
      onTap: _selectDate,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.accentPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Date',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(_date),
                style: AppTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time.format(context),
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      color: AppColors.accentPrimary.withOpacity(0.08),
      border: Border.all(
        color: AppColors.accentPrimary.withOpacity(0.25),
        width: 1.5,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: AppColors.accentPrimary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Total Duration',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            _calculateDuration(),
            style: AppTextStyles.h2.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sleep Quality',
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.accentPrimary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final val = i + 1;
            final isSelected = _quality == val;
            return GestureDetector(
              onTap: () => setState(() => _quality = val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.3)
                      : AppColors.bgSecondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary.withOpacity(0.6)
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentPrimary.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$val',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
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

  Widget _buildAdvancedSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticHelper.lightImpact();
            setState(() => _showAdvanced = !_showAdvanced);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _showAdvanced 
                  ? AppColors.accentPrimary.withOpacity(0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showAdvanced 
                    ? AppColors.accentPrimary.withOpacity(0.3) 
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showAdvanced ? Icons.insights_rounded : Icons.add_chart_rounded,
                  size: 18,
                  color: _showAdvanced ? AppColors.accentPrimary : AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  _showAdvanced ? 'Hide Advanced Metrics' : 'Add Recovery Metrics',
                  style: AppTextStyles.label.copyWith(
                    color: _showAdvanced ? AppColors.accentPrimary : AppColors.textTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showAdvanced
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: _showAdvanced ? AppColors.accentPrimary : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
        if (_showAdvanced) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildSleepStructureInputs(),
          const SizedBox(height: AppSpacing.md),
          _buildRecoveryInputs(),
        ],
      ],
    );
  }

  Widget _buildSleepStructureInputs() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.bgSecondary.withOpacity(0.2),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.accentPrimary),
              const SizedBox(width: 8),
              Text(
                'Sleep Architecture (mins)',
                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildMetricInput('Deep', _deepSleep, (v) => setState(() => _deepSleep = v), AppColors.accentPrimary)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricInput('REM', _remSleep, (v) => setState(() => _remSleep = v), AppColors.accentSkyBlue)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetricInput('Light', _lightSleep, (v) => setState(() => _lightSleep = v), AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricInput('Awake', _awake, (v) => setState(() => _awake = v), AppColors.accentAmber)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryInputs() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.bgSecondary.withOpacity(0.2),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_outline_rounded, size: 18, color: AppColors.accentError),
              const SizedBox(width: 8),
              Text(
                'Vitals & Recovery',
                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildMetricInput(
                  'HRV (ms)', 
                  _hrv, 
                  (v) => setState(() => _hrv = v), 
                  AppColors.accentSuccess,
                  icon: Icons.bolt_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricInput(
                  'RHR (bpm)', 
                  _rhr, 
                  (v) => setState(() => _rhr = v), 
                  AppColors.accentError,
                  icon: Icons.favorite_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricInput(
            'Respiratory Rate (br/m)', 
            _respiratoryRate, 
            (v) => setState(() => _respiratoryRate = v), 
            AppColors.accentSkyBlue,
            icon: Icons.air_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricInput(
    String label, 
    int? value, 
    Function(int?) onChanged, 
    Color themeColor,
    {IconData? icon}
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: themeColor.withOpacity(0.7)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value?.toString() ?? '')..selection = TextSelection.fromPosition(TextPosition(offset: (value?.toString() ?? '').length)),
            keyboardType: TextInputType.number,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold, color: themeColor),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '--',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
            ),
            onChanged: (val) {
              onChanged(int.tryParse(val));
            },
          ),
        ],
      ),
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
        _date.year,
        _date.month,
        _date.day,
        _bedtime.hour,
        _bedtime.minute,
      );

      // Handle overnight wake time
      DateTime wakeDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _waketime.hour,
        _waketime.minute,
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
          deepSleepDuration: _deepSleep,
          lightSleepDuration: _lightSleep,
          remSleepDuration: _remSleep,
          awakeDuration: _awake,
          restingHeartRate: _rhr,
          hrv: _hrv,
          respiratoryRate: _respiratoryRate,
        );
      } else {
        await client.sleepSession.logManualSession(
          userId,
          bedDateTime.toUtc(),
          wakeDateTime.toUtc(),
          _quality,
          deepSleepDuration: _deepSleep,
          lightSleepDuration: _lightSleep,
          remSleepDuration: _remSleep,
          awakeDuration: _awake,
          restingHeartRate: _rhr,
          hrv: _hrv,
          respiratoryRate: _respiratoryRate,
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
        backgroundColor: AppColors.surfaceBase,
        title: const Text('Delete Session?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _handleDelete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.accentError),
            ),
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
