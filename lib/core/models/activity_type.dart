enum ActivityType {
  run,
  bike,
  ski,
  surf,
  other;

  String get emoji => switch (this) {
        ActivityType.run   => '🏃',
        ActivityType.bike  => '🚴',
        ActivityType.ski   => '⛷️',
        ActivityType.surf  => '🏄',
        ActivityType.other => '⚡',
      };

  static ActivityType fromJson(String? value) =>
      ActivityType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ActivityType.other,
      );
}
