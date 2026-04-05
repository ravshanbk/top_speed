import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/lang.dart';
import '../../../core/theme.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../../tracking/widgets/speed_alert_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Units ───────────────────────────────────────────────────────────
          _SectionLabel(l10n.settingsUnits),
          const SizedBox(height: 12),
          _UnitToggleCard(settings: settings),

          const SizedBox(height: 28),

          // ── Speed alert ──────────────────────────────────────────────────────
          _SectionLabel(l10n.settingsAlert),
          const SizedBox(height: 12),
          _AlertCard(settings: settings, l10n: l10n),

          const SizedBox(height: 28),

          // ── Language ─────────────────────────────────────────────────────────
          _SectionLabel(l10n.settingsLanguage),
          const SizedBox(height: 12),
          ...AppLang.values.map(
            (lang) => _LangTile(
              lang: lang,
              selected: settings.lang == lang,
              onTap: () => context.read<SettingsCubit>().setLang(lang),
            ),
          ),

          const SizedBox(height: 28),

          // ── About ────────────────────────────────────────────────────────────
          _SectionLabel(l10n.settingsAbout),
          const SizedBox(height: 12),
          _AboutCard(l10n: l10n),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

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

// ── Unit toggle ───────────────────────────────────────────────────────────────

class _UnitToggleCard extends StatelessWidget {
  final SettingsState settings;
  const _UnitToggleCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['km/h', 'mph'].map((unit) {
          final selected = settings.unitLabel == unit;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!selected) context.read<SettingsCubit>().toggleUnit();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unit,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        selected ? AppColors.background : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Speed alert card ──────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final SettingsState settings;
  final AppLocalizations l10n;
  const _AlertCard({required this.settings, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isSet = settings.alertThresholdMs != null;
    return GestureDetector(
      onTap: () => SpeedAlertSheet.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSet ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSet
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: isSet ? AppColors.accent : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isSet
                    ? '${settings.formatSpeed(settings.alertThresholdMs!)} ${settings.unitLabel}'
                    : l10n.settingsAlertOff,
                style: TextStyle(
                  color: isSet ? AppColors.white : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSet)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.settingsAlertActive,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            const SizedBox(width: 8),
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

// ── Language tile ─────────────────────────────────────────────────────────────

class _LangTile extends StatelessWidget {
  final AppLang lang;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({required this.lang, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                lang.label,
                style: TextStyle(
                  color: selected ? AppColors.accent : AppColors.white,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── About card ────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _AboutCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.speed_rounded, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Speed',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.settingsVersion} 1.0.0',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
