import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/models/activity_type.dart';
import '../../../core/models/session.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/cubit/settings_state.dart';
import '../../history/widgets/session_card.dart' show activityLabel, formatDuration;

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsCubit>().state;
    final storage = context.read<StorageService>();

    final topSpeed   = storage.topSpeedRecord();
    final avgSpeed   = storage.avgSpeedRecord();
    final longest    = storage.longestSession();
    final byActivity = storage.recordsByActivity();

    final hasAny = topSpeed != null || avgSpeed != null || longest != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordsTitle)),
      body: hasAny
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionLabel(l10n.recordAllTime),
                const SizedBox(height: 10),
                if (topSpeed != null)
                  _RecordCard(
                    icon: Icons.speed_rounded,
                    iconColor: AppColors.accent,
                    label: l10n.labelTopSpeed,
                    value: settings.formatSpeed(topSpeed.topSpeedMs),
                    unit: settings.unitLabel,
                    session: topSpeed,
                    settings: settings,
                  ),
                const SizedBox(height: 10),
                if (avgSpeed != null)
                  _RecordCard(
                    icon: Icons.show_chart_rounded,
                    iconColor: AppColors.accent,
                    label: l10n.labelAvgSpeed,
                    value: settings.formatSpeed(avgSpeed.avgSpeedMs),
                    unit: settings.unitLabel,
                    session: avgSpeed,
                    settings: settings,
                  ),
                const SizedBox(height: 10),
                if (longest != null)
                  _RecordCard(
                    icon: Icons.timer_rounded,
                    iconColor: AppColors.accent,
                    label: l10n.labelDuration,
                    value: formatDuration(longest.duration),
                    unit: '',
                    session: longest,
                    settings: settings,
                  ),
                if (byActivity.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ...ActivityType.values
                      .where((t) => byActivity.containsKey(t))
                      .map((t) {
                    final s = byActivity[t]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecordCard(
                        icon: null,
                        emoji: t.emoji,
                        iconColor: AppColors.textSecondary,
                        label: activityLabel(l10n, t),
                        value: settings.formatSpeed(s.topSpeedMs),
                        unit: settings.unitLabel,
                        session: s,
                        settings: settings,
                      ),
                    );
                  }),
                ],
              ],
            )
          : Center(
              child: Text(
                l10n.recordNoData,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final Session session;
  final SettingsState settings;

  const _RecordCard({
    this.icon,
    this.emoji,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.session,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final locale = settings.locale.languageCode;
    final dateStr = DateFormat('d MMM yyyy', locale).format(session.startTime);

    return GestureDetector(
      onTap: () => context.push('/records/detail', extra: session),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: emoji != null
                    ? Text(emoji!, style: const TextStyle(fontSize: 22))
                    : Icon(icon!, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
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
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
