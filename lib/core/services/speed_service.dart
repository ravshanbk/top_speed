import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

enum SpeedSource { gps }

class SpeedData {
  final double speedMs;
  final double topSpeedMs;
  final SpeedSource source;

  const SpeedData({
    required this.speedMs,
    required this.topSpeedMs,
    required this.source,
  });
}

// Noise floor: readings below this are clamped to zero.
// 1.5 m/s ≈ 5.4 km/h — well below any real sport activity.
const _kNoiseFloor = 1.5;

// EMA smoothing factor: 0.3 reacts fast enough for sport but kills brief spikes.
const _kAlpha = 0.3;

class SpeedService {
  final _controller = StreamController<SpeedData>.broadcast();

  StreamSubscription<Position>? _gpsSub;
  bool _running = false;
  double _topSpeedMs = 0;
  double _ema = 0; // exponential moving average of raw GPS speed

  Stream<SpeedData> get stream => _controller.stream;
  double get topSpeedMs => _topSpeedMs;

  Future<void> start() async {
    _running = true;
    _topSpeedMs = 0;
    _ema = 0;

    final permission = await _requestPermission();
    if (!permission) return;

    _startGpsStream();
  }

  void stop() {
    _running = false;
    _gpsSub?.cancel();
    _gpsSub = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  LocationSettings _buildLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Top Speed',
          notificationText: 'Tracking your speed...',
          enableWakeLock: true,
        ),
      );
    } else if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );
  }

  void _startGpsStream() {
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: _buildLocationSettings(),
    ).listen(
      (pos) {
        if (!_running) return;

        // Reject readings where GPS itself reports poor speed accuracy.
        // speedAccuracy == -1 means the platform didn't provide it — allow those.
        if (pos.speedAccuracy > 0 && pos.speedAccuracy > 1.5) return;

        final raw = pos.speed >= 0 ? pos.speed : 0.0;

        // EMA filter: smooth out brief spikes before applying the noise floor.
        _ema = _kAlpha * raw + (1 - _kAlpha) * _ema;

        // Clamp to zero anything below the noise floor.
        final speed = _ema < _kNoiseFloor ? 0.0 : _ema;

        if (speed > _topSpeedMs) _topSpeedMs = speed;
        if (!_controller.isClosed) {
          _controller.add(
            SpeedData(speedMs: speed, topSpeedMs: _topSpeedMs, source: SpeedSource.gps),
          );
        }
      },
      onError: (_) {},
    );
  }

  Future<bool> _requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    // Request "always" on iOS so background updates work even when locked
    if (Platform.isIOS && permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }
    return true;
  }
}
