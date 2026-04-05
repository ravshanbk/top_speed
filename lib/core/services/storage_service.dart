import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../lang.dart';
import '../models/activity_type.dart';
import '../models/session.dart';

class StorageService {
  static const _sessionsKey = 'sessions';
  static const _unitKey     = 'isKmh';
  static const _langKey     = 'lang';
  static const _alertKey    = 'alertThresholdMs';
  static const _maxSessions = 10;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Unit ──────────────────────────────────────────────────────────────────

  bool get isKmh => _prefs.getBool(_unitKey) ?? true;
  Future<void> saveUnit(bool v) => _prefs.setBool(_unitKey, v);

  // ── Language ──────────────────────────────────────────────────────────────

  AppLang get savedLang =>
      AppLang.fromCode(_prefs.getString(_langKey) ?? AppLang.en.name);
  Future<void> saveLang(AppLang lang) => _prefs.setString(_langKey, lang.name);

  // ── Speed alert ───────────────────────────────────────────────────────────

  double? get savedAlertThresholdMs {
    final v = _prefs.getDouble(_alertKey);
    return (v != null && v > 0) ? v : null;
  }

  Future<void> saveAlertThresholdMs(double? ms) async {
    if (ms == null || ms <= 0) {
      await _prefs.remove(_alertKey);
    } else {
      await _prefs.setDouble(_alertKey, ms);
    }
  }

  // ── Sessions ──────────────────────────────────────────────────────────────

  List<Session> getSessions() {
    final raw = _prefs.getStringList(_sessionsKey) ?? [];
    return raw
        .map((s) => Session.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSession(Session session) async {
    final sessions = getSessions();
    sessions.insert(0, session);
    final trimmed = sessions.take(_maxSessions).toList();
    await _prefs.setStringList(
      _sessionsKey,
      trimmed.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<void> deleteSession(String id) async {
    final sessions = getSessions()..removeWhere((s) => s.id == id);
    await _prefs.setStringList(
      _sessionsKey,
      sessions.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  List<String> recentComments({int max = 5}) {
    final seen = <String>{};
    final result = <String>[];
    for (final s in getSessions()) {
      final c = s.comment?.trim();
      if (c != null && c.isNotEmpty && seen.add(c)) {
        result.add(c);
        if (result.length >= max) break;
      }
    }
    return result;
  }

  // ── Personal records ──────────────────────────────────────────────────────

  Session? topSpeedRecord() {
    final s = getSessions();
    if (s.isEmpty) return null;
    return s.reduce((a, b) => a.topSpeedMs > b.topSpeedMs ? a : b);
  }

  Session? avgSpeedRecord() {
    final s = getSessions().where((x) => x.avgSpeedMs > 0).toList();
    if (s.isEmpty) return null;
    return s.reduce((a, b) => a.avgSpeedMs > b.avgSpeedMs ? a : b);
  }

  Session? longestSession() {
    final s = getSessions();
    if (s.isEmpty) return null;
    return s.reduce((a, b) => a.duration > b.duration ? a : b);
  }

  Map<ActivityType, Session> recordsByActivity() {
    final result = <ActivityType, Session>{};
    for (final s in getSessions()) {
      final current = result[s.activityType];
      if (current == null || s.topSpeedMs > current.topSpeedMs) {
        result[s.activityType] = s;
      }
    }
    return result;
  }
}
