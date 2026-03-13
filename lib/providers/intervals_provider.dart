import 'package:synquerra/core/preferences/interval_preferences.dart';
import 'package:flutter/material.dart';

class IntervalsProvider with ChangeNotifier {
  // Add your interval-related logic here
  // lib/core/providers/my_device_provider.dart

  Map<String, String> _localSettings = {};
  Map<String, String> get localSettings => _localSettings;

  // Load from Disk ONCE
  Future<void> loadSettingsFromDisk() async {
    _localSettings = await IntervalPreferences().getAllIntervals();
    notifyListeners();
  }

  // Update both RAM and Disk
  Future<void> setSetting(String key, String value) async {
    // 1. Update RAM (Immediate UI update)
    _localSettings[key] = value;
    notifyListeners();

    // 2. Update Disk (Background Persistence)
    await IntervalPreferences().saveInterval(key, value);
  }
}
