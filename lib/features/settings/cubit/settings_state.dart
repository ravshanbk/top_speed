import 'package:flutter/widgets.dart';
import '../../../core/lang.dart';

// Sentinel for nullable copyWith
const _absent = Object();

class SettingsState {
  final bool isKmh;
  final AppLang lang;
  final double? alertThresholdMs;

  const SettingsState({
    required this.isKmh,
    required this.lang,
    this.alertThresholdMs,
  });

  String get unitLabel => isKmh ? 'km/h' : 'mph';
  Locale get locale    => lang.locale;

  double convert(double ms)       => isKmh ? ms * 3.6 : ms * 2.23694;
  String formatSpeed(double ms)   => convert(ms).toStringAsFixed(1);

  double? get alertThresholdDisplay =>
      alertThresholdMs == null ? null : convert(alertThresholdMs!);

  SettingsState copyWith({
    bool? isKmh,
    AppLang? lang,
    Object? alertThresholdMs = _absent,
  }) {
    return SettingsState(
      isKmh: isKmh ?? this.isKmh,
      lang: lang ?? this.lang,
      alertThresholdMs: identical(alertThresholdMs, _absent)
          ? this.alertThresholdMs
          : alertThresholdMs as double?,
    );
  }
}
