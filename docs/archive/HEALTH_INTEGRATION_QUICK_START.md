# Health Tracking Integration - Quick Start Guide

## 🚀 How to Use the New Features

### For Users

#### 1. Connect Your Health Data

**On Android:**
1. Open Insomnia Butler app
2. Navigate to Settings → Health Data
3. Tap "Connect Health Data"
4. Grant permissions in Health Connect
5. Wait for initial sync (30 days of data)

**On iOS:**
1. Open Insomnia Butler app
2. Navigate to Settings → Health Data
3. Tap "Connect Health Data"
4. Select data types in HealthKit permission sheet
5. Tap "Allow"
6. Wait for initial sync (30 days of data)

#### 2. Import Historical Data

1. Go to Health Data → Import Sleep Data
2. Select date range or use quick select (7/30/90 days)
3. Tap "Import Sleep Data"
4. Wait for import to complete
5. View imported sessions in Sleep History

#### 3. View Sleep Stages

1. Open Sleep History
2. Tap on any sleep session
3. Scroll to "Sleep Stages" section
4. See color-coded timeline and breakdown

---

### For Developers

#### Integrating into Existing Screens

##### 1. Add Health Connection to Settings

```dart
import 'package:insomniabutler_flutter/screens/health/health_connection_screen.dart';
import 'package:insomniabutler_flutter/services/health_data_service.dart';
import 'package:insomniabutler_flutter/services/sleep_sync_service.dart';

// In your settings screen
ListTile(
  leading: Icon(Icons.health_and_safety),
  title: Text('Health Data Connection'),
  subtitle: Text('Connect to HealthKit or Health Connect'),
  onTap: () {
    final healthService = HealthDataService();
    final syncService = SleepSyncService(healthService, client);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthConnectionScreen(
          healthService: healthService,
          syncService: syncService,
        ),
      ),
    );
  },
),
```

##### 2. Add Sync Button to Sleep History

```dart
import 'package:insomniabutler_flutter/services/sleep_sync_service.dart';

// In your sleep history screen app bar
AppBar(
  actions: [
    IconButton(
      icon: Icon(Icons.sync),
      onPressed: () async {
        final syncService = SleepSyncService(healthService, client);
        final result = await syncService.syncLastNDays(7);
        
        if (result != null && result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Synced ${result.sessionsImported} sessions'),
            ),
          );
        }
      },
    ),
  ],
)
```

##### 3. Add Sleep Stage Chart to Session Detail

```dart
import 'package:insomniabutler_flutter/widgets/sleep/sleep_stage_chart.dart';

// In your sleep session detail screen
Column(
  children: [
    // ... other session details ...
    
    SleepStageChart(session: sleepSession),
    
    // ... more details ...
  ],
)
```

##### 4. Add Data Source Badge to Session Cards

```dart
// In your sleep session list item
if (session.sleepDataSource != null)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: session.sleepDataSource == 'healthkit'
          ? Colors.blue.withOpacity(0.2)
          : Colors.green.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          session.sleepDataSource == 'healthkit'
              ? Icons.favorite
              : Icons.health_and_safety,
          size: 14,
          color: session.sleepDataSource == 'healthkit'
              ? Colors.blue
              : Colors.green,
        ),
        SizedBox(width: 4),
        Text(
          session.sleepDataSource == 'healthkit'
              ? 'HealthKit'
              : 'Health Connect',
          style: TextStyle(
            fontSize: 12,
            color: session.sleepDataSource == 'healthkit'
                ? Colors.blue
                : Colors.green,
          ),
        ),
      ],
    ),
  ),
```

##### 5. Implement Auto-Sync on App Launch

```dart
// In your main.dart or app initialization
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _performAutoSync();
  }
  
  Future<void> _performAutoSync() async {
    try {
      final healthService = HealthDataService();
      final syncService = SleepSyncService(healthService, client);
      
      // Auto-sync runs silently in background
      await syncService.autoSync();
    } catch (e) {
      print('Auto-sync error: $e');
      // Don't show error to user for auto-sync
    }
  }
}
```

---

## 🔧 Service Initialization

### Creating Service Instances

```dart
// Create health data service
final healthService = HealthDataService();

// Create sync service (requires client instance)
final syncService = SleepSyncService(
  healthService,
  client, // Your Serverpod client instance
);
```

### Checking Connection Status

```dart
// Check if user has granted permissions
final hasPermissions = await healthService.hasPermissions();

if (hasPermissions) {
  // User is connected, can sync
} else {
  // Show connection prompt
}
```

### Getting Last Sync Time

```dart
final lastSync = await syncService.getLastSyncTime();

if (lastSync != null) {
  print('Last synced: ${DateFormat('MMM dd, yyyy HH:mm').format(lastSync)}');
} else {
  print('Never synced');
}
```

---

## 📊 Displaying New Data Fields

### Sleep Efficiency

```dart
if (session.sleepEfficiency != null)
  Text(
    'Sleep Efficiency: ${session.sleepEfficiency!.toStringAsFixed(1)}%',
    style: TextStyle(
      color: session.sleepEfficiency! >= 85
          ? Colors.green
          : session.sleepEfficiency! >= 75
              ? Colors.orange
              : Colors.red,
    ),
  ),
```

### Time in Bed vs Sleep Time

```dart
final timeInBed = session.timeInBedMinutes ?? 0;
final totalSleep = (session.deepSleepDuration ?? 0) +
                   (session.lightSleepDuration ?? 0) +
                   (session.remSleepDuration ?? 0);

Text('Time in Bed: ${_formatDuration(timeInBed)}');
Text('Total Sleep: ${_formatDuration(totalSleep)}');

String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  return '${hours}h ${mins}m';
}
```

### Interruptions

```dart
if (session.interruptions != null)
  Row(
    children: [
      Icon(Icons.warning_amber, color: Colors.orange),
      SizedBox(width: 8),
      Text('${session.interruptions} interruptions'),
    ],
  ),
```

### Wrist Temperature (iOS)

```dart
if (session.wristTemperature != null)
  Row(
    children: [
      Icon(Icons.thermostat, color: Colors.blue),
      SizedBox(width: 8),
      Text('${session.wristTemperature!.toStringAsFixed(1)}°C'),
    ],
  ),
```

### Device Information

```dart
if (session.deviceModel != null)
  Row(
    children: [
      Icon(Icons.watch, color: Colors.grey),
      SizedBox(width: 8),
      Text(session.deviceModel!),
    ],
  ),
```

---

## 🎨 UI Components Reference

### Available Screens

1. **HealthConnectionScreen** - Connect/disconnect health data
2. **SleepDataImportScreen** - Import historical data
3. **SleepStageChart** - Visualize sleep stages

### Available Services

1. **HealthDataService** - Interact with health platforms
2. **SleepSyncService** - Sync data to backend

### Color Scheme

```dart
// Sleep Stage Colors
const deepSleepColor = Color(0xFF4A90E2);      // Blue
const lightSleepColor = Color(0xFF7ED321);     // Green
const remSleepColor = Color(0xFFBD10E0);       // Purple
const awakeColor = Color(0xFFF5A623);          // Orange
const unspecifiedColor = Color(0xFF9B9B9B);    // Gray

// Platform Colors
const healthKitColor = Color(0xFFFF2D55);      // Apple Red
const healthConnectColor = Color(0xFF00D4AA);  // Android Green
```

---

## 🐛 Debugging

### Enable Logging

```dart
// In HealthDataService and SleepSyncService
// All operations already have print statements for debugging

// To see logs:
// 1. Run app in debug mode
// 2. Check console output
// 3. Look for prefixes like:
//    - "Found X sleep sessions to sync"
//    - "Imported session for..."
//    - "Error importing session: ..."
```

### Common Debug Points

```dart
// Check permissions
print('Has permissions: ${await healthService.hasPermissions()}');

// Check fetched data
final sessions = await healthService.getSleepSessions(start, end, userId);
print('Fetched ${sessions.length} sessions');

// Check sync result
final result = await syncService.syncLastNDays(7);
print('Imported: ${result.sessionsImported}');
print('Failed: ${result.sessionsFailed}');
print('Errors: ${result.errors}');
```

---

## ✅ Testing Checklist

### Before Release

- [ ] Test on Android device with Health Connect
- [ ] Test on iOS device with HealthKit
- [ ] Test permission request flow
- [ ] Test permission denial handling
- [ ] Test sync with no data
- [ ] Test sync with partial data
- [ ] Test sync with complete data
- [ ] Test duplicate detection
- [ ] Test auto-sync on app launch
- [ ] Test manual sync
- [ ] Test import screen
- [ ] Test connection screen
- [ ] Test sleep stage visualization
- [ ] Test data source badges
- [ ] Test disconnect functionality
- [ ] Verify database migration runs
- [ ] Check performance with large datasets

---

## 📚 Additional Resources

### Documentation
- [Android Health Connect Docs](https://developer.android.com/health-and-fitness/guides/health-connect)
- [Apple HealthKit Docs](https://developer.apple.com/documentation/healthkit)
- [Flutter health Package](https://pub.dev/packages/health)

### Files to Review
- `HEALTH_INTEGRATION_SUMMARY.md` - Complete implementation details
- `sleep_tracking_integration_research.md` - Research and data mapping
- `implementation_plan.md` - Original implementation plan

---

**Questions?** Check the implementation summary or review the service code for detailed documentation.
