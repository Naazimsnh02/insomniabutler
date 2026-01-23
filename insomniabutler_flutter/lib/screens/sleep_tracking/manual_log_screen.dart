import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';

class ManualLogScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData; // Pass if editing

  const ManualLogScreen({super.key, this.initialData});

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
  int? _interruptions;

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
      _interruptions = d['interruptions'];
      if (_deepSleep != null ||
          _lightSleep != null ||
          _remSleep != null ||
          _awake != null ||
          _hrv != null ||
          _rhr != null ||
          _respiratoryRate != null ||
          _interruptions != null) {
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
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _waketime = picked;
        }
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
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -100,
            left: -50,
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
            right: -80,
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
                _buildTopBar(isEdit),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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
                                Icons.bedtime_rounded,
                                AppColors.accentPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildTimePicker(
                                'Woke Up',
                                _waketime,
                                () => _selectTime(false),
                                Icons.wb_sunny_rounded,
                                AppColors.accentAmber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildDurationInfo(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildQualityPicker(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildInterruptionsPicker(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildAdvancedSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildSaveButton(isEdit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isEdit) {
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
                isEdit ? 'Update Session' : 'Log Sleep',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEdit ? 'Modify your sleep data' : 'Manually track your rest',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
        borderRadius: 14,
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
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
                'SESSION DATE',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(_date),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimePicker(String label, TimeOfDay time, VoidCallback onTap, IconData icon, Color accentColor) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: accentColor),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            time.format(context),
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDurationInfo() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 24,
      color: AppColors.accentPrimary.withOpacity(0.05),
      border: Border.all(
        color: AppColors.accentPrimary.withOpacity(0.2),
        width: 1.5,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.accentPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Total Sleep Duration',
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary.withOpacity(0.9),
            ),
          ),
          const Spacer(),
          Text(
            _calculateDuration(),
            style: AppTextStyles.h3.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildQualityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SLEEP QUALITY',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: AppColors.accentPrimary,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final val = i + 1;
            final isSelected = _quality == val;
            return GestureDetector(
              onTap: () {
                HapticHelper.lightImpact();
                setState(() => _quality = val);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.gradientPrimary : null,
                  color: isSelected ? null : AppColors.bgSecondary.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentPrimary.withOpacity(0.5)
                        : Colors.white.withOpacity(0.05),
                    width: isSelected ? 2 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentPrimary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$val',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RESTORATIVE', style: AppTextStyles.caption.copyWith(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              Text('EXCELLENT', style: AppTextStyles.caption.copyWith(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildInterruptionsPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WAKE UPS / INTERRUPTIONS',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              const Icon(
                Icons.bedtime_rounded,
                size: 14,
                color: AppColors.accentSkyBlue,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            final val = i;
            final isSelected = _interruptions == val;
            return GestureDetector(
              onTap: () {
                HapticHelper.lightImpact();
                setState(() => _interruptions = val);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentSkyBlue.withOpacity(0.2)
                      : AppColors.bgSecondary.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentSkyBlue.withOpacity(0.5)
                        : Colors.white.withOpacity(0.05),
                    width: isSelected ? 2 : 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$val',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: _showAdvanced
                  ? AppColors.accentPrimary.withOpacity(0.1)
                  : AppColors.bgSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _showAdvanced
                    ? AppColors.accentPrimary.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showAdvanced
                      ? Icons.insights_rounded
                      : Icons.add_chart_rounded,
                  size: 18,
                  color: _showAdvanced
                      ? AppColors.accentPrimary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 10),
                Text(
                  _showAdvanced
                      ? 'HIDE PERFORMANCE METRICS'
                      : 'ADD PERFORMANCE METRICS',
                  style: AppTextStyles.label.copyWith(
                    color: _showAdvanced
                        ? AppColors.accentPrimary
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _showAdvanced
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: _showAdvanced
                      ? AppColors.accentPrimary
                      : AppColors.textTertiary,
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
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildSleepStructureInputs() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.2),
      borderRadius: 28,
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                size: 16,
                color: AppColors.accentPrimary,
              ),
              const SizedBox(width: 10),
              Text(
                'SLEEP STAGES (MINS)',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildMetricInput(
                'Deep',
                _deepSleep,
                (v) => setState(() => _deepSleep = v),
                AppColors.accentPrimary,
              ),
              _buildMetricInput(
                'REM',
                _remSleep,
                (v) => setState(() => _remSleep = v),
                AppColors.accentSkyBlue,
              ),
              _buildMetricInput(
                'Light',
                _lightSleep,
                (v) => setState(() => _lightSleep = v),
                AppColors.textSecondary,
              ),
              _buildMetricInput(
                'Awake',
                _awake,
                (v) => setState(() => _awake = v),
                AppColors.accentAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryInputs() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.bgSecondary.withOpacity(0.2),
      borderRadius: 28,
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_outline_rounded,
                size: 16,
                color: AppColors.accentError,
              ),
              const SizedBox(width: 10),
              Text(
                'RECOVERY VITALS',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
    Color themeColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10, color: themeColor.withOpacity(0.7)),
                const SizedBox(width: 4),
              ],
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value?.toString() ?? '')
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: (value?.toString() ?? '').length),
              ),
            keyboardType: TextInputType.number,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w900,
              color: themeColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '00',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.05)),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimary.withOpacity(0),
            AppColors.bgPrimary.withOpacity(0.8),
            AppColors.bgPrimary,
          ],
        ),
      ),
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
          interruptions: _interruptions,
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
          interruptions: _interruptions,
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
