import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../core/lang.dart';
import '../../core/theme.dart';
import '../../features/settings/cubit/settings_cubit.dart';

class LangPickerSheet extends StatelessWidget {
  const LangPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const LangPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.watch<SettingsCubit>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.chooseLanguage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...AppLang.values.map(
            (lang) => _LangTile(
              lang: lang,
              selected: cubit.state.lang == lang,
              onTap: () {
                cubit.setLang(lang);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final AppLang lang;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(
              lang.label,
              style: TextStyle(
                color: selected ? AppColors.accent : AppColors.white,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_rounded, color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
