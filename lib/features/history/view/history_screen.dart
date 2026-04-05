import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/theme.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/history_cubit.dart';
import '../widgets/session_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(context.read())..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsCubit>().state;
    final state = context.watch<HistoryCubit>().state;
    final locale = settings.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: state.sessions.isEmpty
          ? Center(
              child: Text(
                l10n.historyEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.sessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final session = state.sessions[i];
                return SessionCard(
                  session: session,
                  settings: settings,
                  dateLabel: DateFormat('d MMM yyyy  HH:mm', locale)
                      .format(session.startTime),
                  durationLabel: formatDuration(session.duration),
                  activityLabel: activityLabel(l10n, session.activityType),
                  onDelete: () => context.read<HistoryCubit>().delete(session.id),
                  onTap: () => context.push('/history/detail', extra: session),
                );
              },
            ),
    );
  }
}
