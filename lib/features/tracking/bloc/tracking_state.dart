part of 'tracking_bloc.dart';

enum TrackingStatus {
  idle,
  countdown,
  running,
  /// Speed service stopped; HomeScreen should show EndSessionSheet.
  awaitingSave,
}

class TrackingState {
  final TrackingStatus status;
  final int? countdownValue;
  final double currentSpeedMs;
  final double topSpeedMs;
  final List<double> speedSamples;
  final Duration elapsed;
  final bool alertFired;
  // Populated when status == awaitingSave:
  final Duration? finalDuration;
  final List<String> recentComments;

  const TrackingState({
    required this.status,
    this.countdownValue,
    this.currentSpeedMs = 0,
    this.topSpeedMs = 0,
    this.speedSamples = const [],
    this.elapsed = Duration.zero,
    this.alertFired = false,
    this.finalDuration,
    this.recentComments = const [],
  });

  factory TrackingState.initial() => const TrackingState(status: TrackingStatus.idle);

  double get avgSpeedMs => speedSamples.isEmpty
      ? 0.0
      : speedSamples.reduce((a, b) => a + b) / speedSamples.length;

  TrackingState copyWith({
    TrackingStatus? status,
    Object? countdownValue = _absent,
    double? currentSpeedMs,
    double? topSpeedMs,
    List<double>? speedSamples,
    Duration? elapsed,
    bool? alertFired,
    Object? finalDuration = _absent,
    List<String>? recentComments,
  }) {
    return TrackingState(
      status: status ?? this.status,
      countdownValue: identical(countdownValue, _absent)
          ? this.countdownValue
          : countdownValue as int?,
      currentSpeedMs: currentSpeedMs ?? this.currentSpeedMs,
      topSpeedMs: topSpeedMs ?? this.topSpeedMs,
      speedSamples: speedSamples ?? this.speedSamples,
      elapsed: elapsed ?? this.elapsed,
      alertFired: alertFired ?? this.alertFired,
      finalDuration: identical(finalDuration, _absent)
          ? this.finalDuration
          : finalDuration as Duration?,
      recentComments: recentComments ?? this.recentComments,
    );
  }
}

const _absent = Object();
