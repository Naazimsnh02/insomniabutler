import 'dart:convert';
import 'package:flutter/services.dart';

/// Fetches the server URL from config.json or returns default localhost URL
Future<String> getServerUrl() async {
  try {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = jsonDecode(configString);
    return config['apiUrl'] as String? ?? 'http://localhost:8080/';
  } catch (e) {
    // If config.json doesn't exist or can't be loaded, use localhost
    return 'http://localhost:8080/';
  }
}
