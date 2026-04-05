import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/models/activity_type.dart';
import '../../../core/models/session.dart';
import '../../../core/theme.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../../shared/widgets/speed_graph.dart';
import '../widgets/session_share_card.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsCubit>().state;
    final locale = settings.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => shareSession(context, session, settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM yyyy  HH:mm', locale)
                      .format(session.startTime),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(session.activityType.emoji,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(
                        _activityLabel(l10n, session.activityType),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  settings.formatSpeed(session.topSpeedMs),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 80,
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
            const SizedBox(height: 24),
            if (session.speedSamples.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: SpeedGraph(
                  samples: session.speedSamples,
                  isKmh: settings.isKmh,
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                _DetailStat(
                  label: l10n.labelAvgSpeed,
                  value: settings.formatSpeed(session.avgSpeedMs),
                  unit: settings.unitLabel,
                ),
                const SizedBox(width: 12),
                _DetailStat(
                  label: l10n.labelDuration,
                  value: _formatDuration(session.duration),
                  unit: '',
                ),
              ],
            ),
            if (session.comment != null && session.comment!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addNote,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.comment!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  l10n.btnShare,
                  style: const TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () => shareSession(context, session, settings),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _activityLabel(AppLocalizations l10n, ActivityType t) =>
      switch (t) {
        ActivityType.run   => l10n.activityRun,
        ActivityType.bike  => l10n.activityBike,
        ActivityType.ski   => l10n.activitySki,
        ActivityType.surf  => l10n.activitySurf,
        ActivityType.other => l10n.activityOther,
      };

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m ${d.inSeconds % 60}s';
    }
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _DetailStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
