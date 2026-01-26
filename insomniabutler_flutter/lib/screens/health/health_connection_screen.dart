import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/health_data_service.dart';
import '../../services/sleep_sync_service.dart';

class HealthConnectionScreen extends StatefulWidget {
  final HealthDataService healthService;
  final SleepSyncService syncService;

  const HealthConnectionScreen({
    super.key,
    required this.healthService,
    required this.syncService,
  });

  @override
  State<HealthConnectionScreen> createState() => _HealthConnectionScreenState();
}

class _HealthConnectionScreenState extends State<HealthConnectionScreen> {
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() => _isLoading = true);
    try {
      final hasPermissions = await widget.healthService.hasPermissions();
      setState(() {
        _isConnected = hasPermissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _connectHealthData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final granted = await widget.healthService.requestPermissions();
      
      if (granted) {
        setState(() {
          _isConnected = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Successfully connected to health data'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Trigger initial sync
        _performInitialSync();
      } else {
        setState(() {
          _errorMessage = 'Permission denied. Please grant access in Settings.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _performInitialSync() async {
    try {
      final result = await widget.syncService.syncLastNDays(30);
      
      if (mounted && result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📥 Imported ${result.sessionsImported} sleep sessions',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('Error during initial sync: $e');
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _isConnected = false;
      _errorMessage = null;
    });

    await widget.syncService.clearSyncData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from health data'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformName = Platform.isIOS ? 'Apple HealthKit' : 'Health Connect';
    final platformIcon = Platform.isIOS ? Icons.favorite : Icons.health_and_safety;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1125),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Health Data Connection',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform Icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F3A),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: _isConnected
                              ? const Color(0xFF00D4AA)
                              : const Color(0xFF6C5CE7),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        platformIcon,
                        size: 60,
                        color: _isConnected
                            ? const Color(0xFF00D4AA)
                            : const Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Platform Name
                  Center(
                    child: Text(
                      platformName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Connection Status
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isConnected
                            ? const Color(0xFF00D4AA).withOpacity(0.2)
                            : const Color(0xFF6C5CE7).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isConnected ? '✓ Connected' : 'Not Connected',
                        style: TextStyle(
                          color: _isConnected
                              ? const Color(0xFF00D4AA)
                              : const Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Benefits Section
                  _buildBenefitsSection(),
                  const SizedBox(height: 32),

                  // Privacy Section
                  _buildPrivacySection(),
                  const SizedBox(height: 32),

                  // Action Button
                  if (!_isConnected)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _connectHealthData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Connect Health Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _disconnect,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Disconnect',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What you get:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            Icons.bedtime,
            'Automatic Sleep Tracking',
            'Your sleep data syncs automatically from your device',
          ),
          _buildBenefitItem(
            Icons.insights,
            'Detailed Sleep Stages',
            'See deep, light, REM, and awake periods',
          ),
          _buildBenefitItem(
            Icons.favorite,
            'Health Metrics',
            'Heart rate, HRV, and respiratory rate during sleep',
          ),
          _buildBenefitItem(
            Icons.analytics,
            'Better Insights',
            'More accurate data leads to better recommendations',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4AA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4AA).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock, color: Color(0xFF00D4AA)),
              SizedBox(width: 8),
              Text(
                'Your Privacy Matters',
                style: TextStyle(
                  color: Color(0xFF00D4AA),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• All health data stays on your device\n'
            '• You control what data is shared\n'
            '• Data is only synced when you choose\n'
            '• You can disconnect anytime',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
