import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../services/account_settings_service.dart';
import '../../utils/haptic_helper.dart';

class DistractionSettingsScreen extends StatefulWidget {
  const DistractionSettingsScreen({super.key});

  @override
  State<DistractionSettingsScreen> createState() => _DistractionSettingsScreenState();
}

class _DistractionSettingsScreenState extends State<DistractionSettingsScreen> {
  bool _isEnabled = false;
  List<AppInfo> _installedApps = [];
  List<String> _blockedPackages = [];
  bool _isLoading = true;
  String _bedtimeStart = '22:00';
  String _bedtimeEnd = '06:00';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isEnabled = await AccountSettingsService.getDistractionBlockingEnabled();
    final blocked = await AccountSettingsService.getBlockedApps();
    final start = await AccountSettingsService.getDistractionBedtimeStart();
    final end = await AccountSettingsService.getDistractionBedtimeEnd();
    
    final apps = await InstalledApps.getInstalledApps(
      withIcon: true,
    );
    
    // Filter out some system apps or current app if needed
    // For now show all with icons

    if (mounted) {
      setState(() {
        _isEnabled = isEnabled;
        _blockedPackages = blocked;
        _installedApps = apps;
        _bedtimeStart = start;
        _bedtimeEnd = end;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleEnabled(bool value) async {
    if (value) {
      // Check Notification permission
      final notifyStatus = await Permission.notification.status;
      if (!notifyStatus.isGranted) {
        final request = await Permission.notification.request();
        if (!request.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification permission is required for prompts.')),
            );
          }
          // We don't block enabling, as they might still want it for internal tracking or basic toasts later, 
          // but strictly speaking notifications are key now.
        }
      }
      
      // Check Usage Stats permission
      bool usageOk = await UsageStats.checkUsagePermission() ?? false;
      if (!usageOk) {
        await UsageStats.grantUsagePermission();
        // Check again after return
        usageOk = await UsageStats.checkUsagePermission() ?? false;
      }

      if (!usageOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usage access is required to detect distracting apps')),
          );
        }
        return;
      }
    }

    await AccountSettingsService.setDistractionBlockingEnabled(value);
    setState(() => _isEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Distraction Blocking', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary))
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildBedtimeSection(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'SELECT APPS TO BLOCK',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final app = _installedApps[index];
                      final isBlocked = _blockedPackages.contains(app.packageName);
                      return _buildAppTile(app, isBlocked);
                    },
                    childCount: _installedApps.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Nudges',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Show a gentle reminder when you open distracting apps during bedtime.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isEnabled,
            activeColor: AppColors.accentPrimary,
            onChanged: _toggleEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildBedtimeSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      child: Column(
        children: [
          _buildTimeRow('Bedtime Starts', _bedtimeStart, (val) async {
            await AccountSettingsService.setDistractionBedtimeStart(val);
            setState(() => _bedtimeStart = val);
          }),
          const Divider(color: Colors.white10, height: 32),
          _buildTimeRow('Bedtime Ends', _bedtimeEnd, (val) async {
            await AccountSettingsService.setDistractionBedtimeEnd(val);
            setState(() => _bedtimeEnd = val);
          }),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String title, String time, Function(String) onSave) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.body),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: int.parse(time.split(':')[0]),
                minute: int.parse(time.split(':')[1]),
              ),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.accentPrimary,
                      onPrimary: Colors.white,
                      surface: AppColors.bgSecondary,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              onSave(formatted);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppTile(AppInfo app, bool isBlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 16,
        color: isBlocked ? AppColors.accentPrimary.withOpacity(0.1) : AppColors.bgSecondary.withOpacity(0.2),
        child: Row(
          children: [
            if (app.icon != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(app.icon!, width: 40, height: 40),
              )
            else
              const Icon(Icons.android, color: AppColors.textTertiary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name ?? 'Unknown',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    app.packageName ?? '',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isBlocked,
              activeColor: AppColors.accentPrimary,
              shape: RoundedRectangleChanges.circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Assuming some defaults
              onChanged: (val) async {
                HapticHelper.lightImpact();
                final newList = List<String>.from(_blockedPackages);
                if (val == true) {
                  newList.add(app.packageName!);
                } else {
                  newList.remove(app.packageName);
                }
                await AccountSettingsService.setBlockedApps(newList);
                setState(() => _blockedPackages = newList);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to fix the Checkbox shape if property not found
class RoundedRectangleChanges {
  static bool circle = false;
}
