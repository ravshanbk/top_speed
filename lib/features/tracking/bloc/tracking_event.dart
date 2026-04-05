part of 'tracking_bloc.dart';

abstract class TrackingEvent {}

class TrackingStartRequested extends TrackingEvent {}

class TrackingStopRequested extends TrackingEvent {}

/// Emitted by HomeScreen after user fills EndSessionSheet.
class SessionSaved extends TrackingEvent {
  final Session session;
  SessionSaved(this.session);
}

/// Emitted by HomeScreen when user discards the session.
class SessionDiscarded extends TrackingEvent {}

// ── Internal events ──────────────────────────────────────────────────────────

class _CountdownTicked extends TrackingEvent {
  final int value; // 3, 2, 1, 0 (0 = "GO!")
  _CountdownTicked(this.value);
}

class _CountdownCompleted extends TrackingEvent {}

class _SpeedDataReceived extends TrackingEvent {
  final SpeedData data;
  _SpeedDataReceived(this.data);
}

class _ElapsedTicked extends TrackingEvent {
  final Duration elapsed;
  final double currentSpeedMs;
  _ElapsedTicked(this.elapsed, this.currentSpeedMs);
}
