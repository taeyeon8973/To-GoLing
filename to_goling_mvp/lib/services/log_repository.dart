import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log_entry.dart';

class LogRepository {
  static const _key = 'logs';

  Future<List<LogEntry>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => LogEntry.fromJson(e)).toList();
  }

  Future<void> saveLogs(List<LogEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(logs.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> addLog(LogEntry log) async {
    final logs = await getLogs();
    logs.add(log);
    await saveLogs(logs);
  }
}

