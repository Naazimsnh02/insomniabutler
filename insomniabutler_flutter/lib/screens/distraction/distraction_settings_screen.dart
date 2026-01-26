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
        : Stack(
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
                    color: AppColors.accentPrimary.withOpacity(0.05),
                  ),
                ),
              ),
              
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.containerPadding,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSectionHeader('Schedule Window'),
                          const SizedBox(height: AppSpacing.md),
                          _buildBedtimeSection(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSectionHeader('Apps to Nudge'),
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
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1.5,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentPrimary.withOpacity(0.2)),
            ),
            child: const Icon(Icons.bolt_rounded, color: AppColors.accentPrimary, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Nudges',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Show a gentle reminder when you open distracting apps during bedtime.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _isEnabled,
              activeColor: AppColors.accentPrimary,
              activeTrackColor: AppColors.accentPrimary.withOpacity(0.3),
              onChanged: _toggleEnabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedtimeSection() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      child: Column(
        children: [
          _buildTimeRow(
            icon: Icons.bedtime_rounded,
            title: 'Bedtime Starts',
            time: _bedtimeStart,
            iconColor: AppColors.accentLavender,
            onSave: (val) async {
              await AccountSettingsService.setDistractionBedtimeStart(val);
              setState(() => _bedtimeStart = val);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64, right: 16),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
          ),
          _buildTimeRow(
            icon: Icons.wb_sunny_rounded,
            title: 'Bedtime Ends',
            time: _bedtimeEnd,
            iconColor: Colors.orangeAccent,
            onSave: (val) async {
              await AccountSettingsService.setDistractionBedtimeEnd(val);
              setState(() => _bedtimeEnd = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required IconData icon,
    required String title,
    required String time,
    required Color iconColor,
    required Function(String) onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildValueBox(_formatTime(time), () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: int.parse(time.split(':')[0]),
                minute: int.parse(time.split(':')[1]),
              ),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.accentPrimary,
                      surface: AppColors.bgSecondary,
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
          }, color: iconColor),
        ],
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final h = hour % 12 == 0 ? 12 : hour % 12;
      final m = minute.toString().padLeft(2, '0');
      return '$h:$m $ampm';
    } catch (e) {
      return timeStr;
    }
  }

  Widget _buildValueBox(String value, VoidCallback onTap, {Color? color}) {
    final themeColor = color ?? AppColors.accentPrimary;
    return InkWell(
      onTap: () {
        HapticHelper.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: themeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            color: themeColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAppTile(AppInfo app, bool isBlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 20,
        color: isBlocked 
            ? AppColors.accentPrimary.withOpacity(0.08) 
            : AppColors.bgSecondary.withOpacity(0.3),
        border: Border.all(
          color: isBlocked 
              ? AppColors.accentPrimary.withOpacity(0.2) 
              : Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            if (app.icon != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(app.icon!, width: 44, height: 44),
                ),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.android_rounded, color: AppColors.textTertiary, size: 24),
              ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    app.name ?? 'Unknown',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.packageName ?? '',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: isBlocked,
                activeColor: AppColors.accentPrimary,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
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
