import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../core/theme.dart';
import '../features/tracking/bloc/tracking_bloc.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        l10n: l10n,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final AppLocalizations l10n;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hide bottom nav during active tracking session
    final isTracking = context.watch<TrackingBloc>().state.status ==
        TrackingStatus.running;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: isTracking ? 0 : null,
      child: isTracking
          ? const SizedBox.shrink()
          : Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.speed_rounded,
                        label: l10n.navTrack,
                        selected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.history_rounded,
                        label: l10n.navHistory,
                        selected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      _NavItem(
                        icon: Icons.emoji_events_rounded,
                        label: l10n.navRecords,
                        selected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.tune_rounded,
                        label: l10n.navSettings,
                        selected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
