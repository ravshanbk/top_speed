import 'package:flutter/material.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/models/activity_type.dart';
import '../../../core/models/session.dart';
import '../../../core/theme.dart';
import '../../settings/cubit/settings_state.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final SettingsState settings;
  final String dateLabel;
  final String durationLabel;
  final String activityLabel;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.session,
    required this.settings,
    required this.dateLabel,
    required this.durationLabel,
    required this.activityLabel,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${session.activityType.emoji} $activityLabel',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  settings.formatSpeed(session.topSpeedMs),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 4),
                  child: Text(
                    settings.unitLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                if (session.avgSpeedMs > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'AVG',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            settings.formatSpeed(session.avgSpeedMs),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2, left: 3),
                            child: Text(
                              settings.unitLabel,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text(
                  durationLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 16),
              ],
            ),
            if (session.comment != null && session.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.comment!,
                  style: const TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String activityLabel(AppLocalizations l10n, ActivityType t) => switch (t) {
      ActivityType.run   => l10n.activityRun,
      ActivityType.bike  => l10n.activityBike,
      ActivityType.ski   => l10n.activitySki,
      ActivityType.surf  => l10n.activitySurf,
      ActivityType.other => l10n.activityOther,
    };

String formatDuration(Duration d) {
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
  return '${d.inSeconds}s';
}
