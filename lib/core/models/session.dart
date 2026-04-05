import 'activity_type.dart';

class Session {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double topSpeedMs;
  final double avgSpeedMs;
  final ActivityType activityType;
  final List<double> speedSamples;
  final String? comment;

  const Session({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.topSpeedMs,
    required this.avgSpeedMs,
    required this.activityType,
    required this.speedSamples,
    this.comment,
  });

  Duration get duration => endTime.difference(startTime);

  double get topSpeedKmh => topSpeedMs * 3.6;
  double get topSpeedMph => topSpeedMs * 2.23694;
  double get avgSpeedKmh => avgSpeedMs * 3.6;
  double get avgSpeedMph => avgSpeedMs * 2.23694;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'topSpeedMs': topSpeedMs,
        'avgSpeedMs': avgSpeedMs,
        'activityType': activityType.name,
        'speedSamples': speedSamples,
        'comment': comment,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        topSpeedMs: (json['topSpeedMs'] as num).toDouble(),
        avgSpeedMs: (json['avgSpeedMs'] as num? ?? 0).toDouble(),
        activityType: ActivityType.fromJson(json['activityType'] as String?),
        speedSamples: (json['speedSamples'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
        comment: json['comment'] as String?,
      );
}
