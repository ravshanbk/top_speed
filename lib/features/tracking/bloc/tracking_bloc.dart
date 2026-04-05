import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/models/session.dart';
import '../../../core/services/speed_service.dart';
import '../../../core/services/storage_service.dart';
import '../../settings/cubit/settings_cubit.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final SpeedService _speedService;
  final StorageService _storage;
  final SettingsCubit _settings;

  StreamSubscription<SpeedData>? _speedSub;
  Timer? _elapsedTimer;
  Timer? _countdownTimer;
  DateTime? _sessionStart;

  TrackingBloc({
    required SpeedService speedService,
    required StorageService storage,
    required SettingsCubit settings,
  })  : _speedService = speedService,
        _storage = storage,
        _settings = settings,
        super(TrackingState.initial()) {
    on<TrackingStartRequested>(_onStartRequested);
    on<TrackingStopRequested>(_onStopRequested);
    on<SessionSaved>(_onSessionSaved);
    on<SessionDiscarded>(_onSessionDiscarded);
    on<_CountdownTicked>(_onCountdownTicked);
    on<_CountdownCompleted>(_onCountdownCompleted);
    on<_SpeedDataReceived>(_onSpeedDataReceived);
    on<_ElapsedTicked>(_onElapsedTicked);
  }

  // ── Event handlers ─────────────────────────────────────────────────────────

  void _onStartRequested(TrackingStartRequested event, Emitter<TrackingState> emit) {
    emit(state.copyWith(status: TrackingStatus.countdown, countdownValue: 3));
    _startCountdown();
  }

  void _onCountdownTicked(_CountdownTicked event, Emitter<TrackingState> emit) {
    HapticFeedback.lightImpact();
    emit(state.copyWith(countdownValue: event.value));
  }

  Future<void> _onCountdownCompleted(
    _CountdownCompleted event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(
      status: TrackingStatus.running,
      countdownValue: null,
      currentSpeedMs: 0,
      topSpeedMs: 0,
      speedSamples: [],
      elapsed: Duration.zero,
      alertFired: false,
    ));

    await WakelockPlus.enable();
    _sessionStart = DateTime.now();

    _speedSub = _speedService.stream.listen((data) {
      if (!isClosed) add(_SpeedDataReceived(data));
    });
    await _speedService.start();

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sessionStart != null && !isClosed) {
        add(_ElapsedTicked(
          DateTime.now().difference(_sessionStart!),
          state.currentSpeedMs,
        ));
      }
    });
  }

  void _onStopRequested(TrackingStopRequested event, Emitter<TrackingState> emit) {
    _speedService.stop();
    _speedSub?.cancel();
    _speedSub = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    WakelockPlus.disable();

    final finalDuration = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;
    _sessionStart = null;

    emit(state.copyWith(
      status: TrackingStatus.awaitingSave,
      finalDuration: finalDuration,
      recentComments: _storage.recentComments(),
    ));
  }

  Future<void> _onSessionSaved(SessionSaved event, Emitter<TrackingState> emit) async {
    await _storage.saveSession(event.session);
    emit(TrackingState.initial());
  }

  void _onSessionDiscarded(SessionDiscarded event, Emitter<TrackingState> emit) {
    emit(TrackingState.initial());
  }

  void _onSpeedDataReceived(_SpeedDataReceived event, Emitter<TrackingState> emit) {
    final data = event.data;
    final prevTop = state.topSpeedMs;

    if (data.topSpeedMs > prevTop + 0.1) {
      HapticFeedback.heavyImpact();
    }

    // Speed alert
    final alertMs = _settings.state.alertThresholdMs;
    bool alertFired = state.alertFired;
    if (alertMs != null) {
      if (!alertFired && data.speedMs >= alertMs) {
        alertFired = true;
        HapticFeedback.vibrate();
      } else if (data.speedMs < alertMs * 0.9) {
        alertFired = false;
      }
    }

    emit(state.copyWith(
      currentSpeedMs: data.speedMs,
      topSpeedMs: data.topSpeedMs,
      alertFired: alertFired,
    ));
  }

  void _onElapsedTicked(_ElapsedTicked event, Emitter<TrackingState> emit) {
    emit(state.copyWith(
      elapsed: event.elapsed,
      speedSamples: [...state.speedSamples, event.currentSpeedMs],
    ));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _startCountdown() {
    int count = 2; // 3 already emitted in _onStartRequested
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (count >= 0) {
        add(_CountdownTicked(count));
        count--;
      } else {
        timer.cancel();
        add(_CountdownCompleted());
      }
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _elapsedTimer?.cancel();
    _speedSub?.cancel();
    _speedService.dispose();
    WakelockPlus.disable();
    return super.close();
  }
}
