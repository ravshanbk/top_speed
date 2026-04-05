import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/models/activity_type.dart';
import '../../../core/models/session.dart';
import '../../../core/theme.dart';
import '../../settings/cubit/settings_state.dart';
import '../../../shared/widgets/speed_graph.dart';

class SessionShareCard extends StatelessWidget {
  final Session session;
  final SettingsState settings;
  final ScreenshotController screenshotController;

  const SessionShareCard({
    super.key,
    required this.session,
    required this.settings,
    required this.screenshotController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = settings.locale.languageCode;
    final dateStr =
        DateFormat('d MMM yyyy  HH:mm', locale).format(session.startTime);

    return Screenshot(
      controller: screenshotController,
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.activityType.emoji}  ${_activityLabel(l10n, session)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'TOP SPEED',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  settings.formatSpeed(session.topSpeedMs),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    settings.unitLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              l10n.labelTopSpeed,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            if (session.speedSamples.isNotEmpty)
              SpeedGraph(
                samples: session.speedSamples,
                isKmh: settings.isKmh,
                height: 70,
              ),
            const SizedBox(height: 16),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _MiniStat(
                  label: l10n.labelAvgSpeed,
                  value: settings.formatSpeed(session.avgSpeedMs),
                  unit: settings.unitLabel,
                ),
                _MiniStat(
                  label: l10n.labelDuration,
                  value: _formatDuration(session.duration),
                  unit: '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _activityLabel(AppLocalizations l10n, Session s) =>
      switch (s.activityType) {
        ActivityType.run   => l10n.activityRun,
        ActivityType.bike  => l10n.activityBike,
        ActivityType.ski   => l10n.activitySki,
        ActivityType.surf  => l10n.activitySurf,
        ActivityType.other => l10n.activityOther,
      };

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> shareSession(
  BuildContext context,
  Session session,
  SettingsState settings,
) async {
  final controller = ScreenshotController();

  final bytes = await controller.captureFromLongWidget(
    MediaQuery(
      data: MediaQuery.of(context),
      child: Localizations(
        locale: settings.locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: SessionShareCard(
          session: session,
          settings: settings,
          screenshotController: controller,
        ),
      ),
    ),
    pixelRatio: 3.0,
    context: context,
  );

  final xFile = XFile.fromData(
    bytes,
    mimeType: 'image/png',
    name: 'top_speed_${session.id}.png',
  );
  await Share.shareXFiles([xFile]);
}
