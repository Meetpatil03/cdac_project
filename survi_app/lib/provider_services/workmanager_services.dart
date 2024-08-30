import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkManagerState with ChangeNotifier {
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  WorkManagerState() {
    _loadState();
  }

  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isRunning = prefs.getBool('isWorkManagerRunning') ?? false;
    notifyListeners();
  }

  Future<void> startWorkManager() async {
    await startWorkManager();
    _isRunning = true;
    notifyListeners();
    _saveState();
  }

  Future<void> stopWorkManager() async {
    await stopWorkManager();
    _isRunning = false;
    notifyListeners();
    _saveState();
  }

  Future<void> _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isWorkManagerRunning', _isRunning);
  }
}
