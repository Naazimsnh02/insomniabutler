import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/sleep_sync_service.dart';
import '../../utils/haptic_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../core/theme.dart';

class SleepDataImportScreen extends StatefulWidget {
  final SleepSyncService syncService;

  const SleepDataImportScreen({
    super.key,
    required this.syncService,
  });

  @override
  State<SleepDataImportScreen> createState() => _SleepDataImportScreenState();
}

class _SleepDataImportScreenState extends State<SleepDataImportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isImporting = false;

  Future<void> _selectStartDate() async {
    HapticHelper.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              surface: AppColors.bgSecondary,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.bgPrimary,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    HapticHelper.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              surface: AppColors.bgSecondary,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.bgPrimary,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _importData() async {
    HapticHelper.mediumImpact();
    setState(() {
      _isImporting = true;
    });

    try {
      final result = await widget.syncService.syncSleepData(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
      });
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showResultDialog(SyncResult result) {
    HapticHelper.success();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        content: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: result.success ? AppColors.accentPrimary.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    result.success ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                    color: result.success ? AppColors.accentPrimary : AppColors.error,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  result.success ? 'Sync Complete' : 'Sync Partial',
                  style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Processed sleep data from ${DateFormat('MMM d').format(_startDate)} to ${DateFormat('MMM d').format(_endDate)}.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 24),
                _buildStatRow(Icons.file_download_done_rounded, 'Sessions Imported', result.sessionsImported.toString()),
                const SizedBox(height: 12),
                _buildStatRow(Icons.error_outline_rounded, 'Errors Encountered', result.errors.length.toString()),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Back to Journey',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    HapticHelper.error();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                const Text('Import Failed', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Text(error, textAlign: TextAlign.center, style: AppTextStyles.bodySm),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss', style: TextStyle(color: AppColors.accentPrimary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final daysDiff = _endDate.difference(_startDate).inDays;

    return Stack(
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

        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Historical Sync',
                            style: AppTextStyles.h2.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.0,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 8),
                          Text(
                            'Select a date range to import sleep data from your connected health platforms.',
                            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary, fontSize: 15),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          const SizedBox(height: 32),
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'RANGE CONFIGURATION',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                fontSize: 10,
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 12),
                          
                          GlassCard(
                            borderRadius: 28,
                            color: AppColors.bgSecondary.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.2,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _buildDateSelectorRow(
                                    label: 'Sync from',
                                    date: _startDate,
                                    onTap: _selectStartDate,
                                    icon: Icons.calendar_today_rounded,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(color: Colors.white.withOpacity(0.08), height: 1),
                                  ),
                                  _buildDateSelectorRow(
                                    label: 'Until',
                                    date: _endDate,
                                    onTap: _selectEndDate,
                                    icon: Icons.event_rounded,
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentPrimary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.accentPrimary.withOpacity(0.15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 16, color: AppColors.accentPrimary),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$daysDiff days selected'.toUpperCase(),
                                          style: AppTextStyles.label.copyWith(
                                            color: AppColors.accentPrimary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0),
                          
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'PRESETS',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                fontSize: 10,
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(child: _buildPresetButton('7 Days', 7)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildPresetButton('30 Days', 30)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildPresetButton('90 Days', 90)),
                            ],
                          ).animate().fadeIn(delay: 450.ms),
                          
                          const SizedBox(height: 80), // Space for button
                        ],
                      ),
                    ),
                  ),
                  _buildBottomAction(),
                ],
              ),
            ),
          ),
        ),
      ],
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
          Text(
            'Sync Health Data',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 48), // Spacer
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
          color: Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimary.withOpacity(0),
            AppColors.bgPrimary,
          ],
        ),
      ),
      child: PrimaryButton(
        text: _isImporting ? 'Discovering...' : 'Begin Discovery',
        isLoading: _isImporting,
        onPressed: _importData,
        icon: Icons.sync_rounded,
      ),
    );
  }

  Widget _buildDateSelectorRow({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppColors.accentPrimary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(), 
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMMM d, yyyy').format(date),
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, int days) {
    final isSelected = _endDate.difference(_startDate).inDays == days;
    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        setState(() {
          _endDate = DateTime.now();
          _startDate = _endDate.subtract(Duration(days: days));
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.gradientPrimary : null,
          color: isSelected ? null : AppColors.bgSecondary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected 
              ? AppColors.accentPrimary.withOpacity(0.6) 
              : Colors.white.withOpacity(0.12),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.accentPrimary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.accentPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            label, 
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value, 
            style: AppTextStyles.h3.copyWith(
              fontSize: 18, 
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
