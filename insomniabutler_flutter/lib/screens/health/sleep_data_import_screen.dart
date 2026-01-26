import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/sleep_sync_service.dart';
import '../../utils/haptic_helper.dart';
import '../../widgets/glass_card.dart';
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
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back to Journey', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodySm),
          const Spacer(),
          Text(value, style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.accentPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysDiff = _endDate.difference(_startDate).inDays;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Sync Health Data',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Historical Sync',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 8),
              Text(
                'Select a date range to import sleep data from your connected health platforms.',
                style: AppTextStyles.body.copyWith(color: AppColors.textTertiary, fontSize: 15),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 32),
              
              Text(
                'Range Configuration',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              
              GlassCard(
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
                        child: Divider(color: AppColors.divider.withOpacity(0.5), height: 1),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.accentPrimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentPrimary.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.accentPrimary),
                            const SizedBox(width: 8),
                            Text(
                              '$daysDiff Days Selected',
                              style: AppTextStyles.label.copyWith(color: AppColors.accentPrimary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.98, 0.98)),
              
              const SizedBox(height: 32),
              Text(
                'Presets',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
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
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.selectionGlow,
                  ),
                  child: ElevatedButton(
                    onPressed: _isImporting ? null : _importData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isImporting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'Begin Discovery',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ).animate().fadeIn(delay: 550.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.accentPrimary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMMM d, yyyy').format(date),
                  style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textDisabled),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary.withOpacity(0.15) : AppColors.bgSecondary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary.withOpacity(0.5) : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
