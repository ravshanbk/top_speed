import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/models/session.dart';
import '../../../core/theme.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/cubit/settings_state.dart';
import '../bloc/tracking_bloc.dart';
import '../widgets/end_session_sheet.dart';
import '../../../shared/widgets/speed_graph.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackingBloc, TrackingState>(
      listenWhen: (prev, curr) =>
          curr.status == TrackingStatus.awaitingSave &&
          prev.status != TrackingStatus.awaitingSave,
      listener: (context, state) => _showEndSheet(context, state),
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final settings = context.watch<SettingsCubit>().state;
        final alertSet = settings.alertThresholdMs != null;

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(l10n.appTitle),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SourceChip(
                            running: state.status == TrackingStatus.running,
                            l10n: l10n,
                          ),
                          if (state.status == TrackingStatus.running)
                            Text(
                              _formatElapsed(state.elapsed),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        settings.formatSpeed(state.currentSpeedMs),
                        style: TextStyle(
                          color: state.status == TrackingStatus.running
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 110,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _UnitToggle(settings: settings),
                      const SizedBox(height: 20),
                      if (state.status == TrackingStatus.running &&
                          state.speedSamples.length > 1) ...[
                        SpeedGraph(
                          samples: state.speedSamples,
                          isKmh: settings.isKmh,
                          height: 72,
                          windowSeconds: 60,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: l10n.labelTopSpeed,
                              value: settings.formatSpeed(state.topSpeedMs),
                              unit: settings.unitLabel,
                              valueColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: l10n.labelAvgSpeed,
                              value: settings.formatSpeed(state.avgSpeedMs),
                              unit: settings.unitLabel,
                              valueColor: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (alertSet) ...[
                        const SizedBox(height: 10),
                        _AlertBadge(
                          label: l10n.alertActive,
                          value:
                              '${settings.formatSpeed(settings.alertThresholdMs!)} ${settings.unitLabel}',
                        ),
                      ],
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: state.status == TrackingStatus.countdown
                              ? null
                              : () {
                                  if (state.status == TrackingStatus.running) {
                                    context
                                        .read<TrackingBloc>()
                                        .add(TrackingStopRequested());
                                  } else {
                                    context
                                        .read<TrackingBloc>()
                                        .add(TrackingStartRequested());
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.status == TrackingStatus.running
                                ? AppColors.danger
                                : AppColors.accent,
                            foregroundColor: AppColors.background,
                            disabledBackgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            state.status == TrackingStatus.running
                                ? l10n.btnStop
                                : l10n.btnStart,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Countdown overlay
            if (state.status == TrackingStatus.countdown)
              _CountdownOverlay(value: state.countdownValue ?? 3, l10n: l10n),
          ],
        );
      },
    );
  }

  Future<void> _showEndSheet(BuildContext context, TrackingState state) async {
    final settings = context.read<SettingsCubit>().state;
    final session = await showModalBottomSheet<Session>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EndSessionSheet(
        duration: state.finalDuration ?? Duration.zero,
        topSpeedMs: state.topSpeedMs,
        avgSpeedMs: state.avgSpeedMs,
        speedSamples: state.speedSamples,
        recentComments: state.recentComments,
        settings: settings,
      ),
    );

    if (!context.mounted) return;

    if (session != null) {
      context.read<TrackingBloc>().add(SessionSaved(session));
    } else {
      context.read<TrackingBloc>().add(SessionDiscarded());
    }
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

// ── Countdown overlay ─────────────────────────────────────────────────────────

class _CountdownOverlay extends StatefulWidget {
  final int value;
  final AppLocalizations l10n;

  const _CountdownOverlay({required this.value, required this.l10n});

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _ring;
  late Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _buildAnimations();
    _anim.forward();
  }

  void _buildAnimations() {
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _anim,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    // Ring drains 1→0 over the full 900 ms, then the next number resets it
    _ring = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.linear),
    );
    // Slight fade-out at the tail end so the transition isn't jarring
    _bgOpacity = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _anim,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void didUpdateWidget(_CountdownOverlay old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGo = widget.value == 0;
    final ringColor = isGo ? AppColors.accent : AppColors.white;
    final label = isGo ? widget.l10n.countdownGo : '${widget.value}';

    return Positioned.fill(
      child: Container(
        color: AppColors.background.withValues(alpha: 0.93),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (context, child) {
                return Opacity(
                  opacity: _bgOpacity.value,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring track
                        SizedBox.expand(
                          child: CustomPaint(
                            painter: _RingPainter(
                              progress: 1.0,
                              color: AppColors.border,
                              strokeWidth: 4,
                            ),
                          ),
                        ),
                        // Animated drain ring
                        SizedBox.expand(
                          child: CustomPaint(
                            painter: _RingPainter(
                              progress: isGo ? 1.0 : _ring.value,
                              color: ringColor,
                              strokeWidth: 4,
                              glow: isGo,
                            ),
                          ),
                        ),
                        // Number
                        ScaleTransition(
                          scale: _scale,
                          child: Material(

                            child: Text(
                              label,
                              style: TextStyle(
                                color: isGo ? AppColors.accent : AppColors.white,
                                fontSize: isGo ? 72 : 110,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Step dots: filled for counts that have passed
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                // dot index 0 = "3", 1 = "2", 2 = "1"
                // a dot is filled when that count has already been shown
                final passed = (3 - i) > widget.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: passed ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: passed ? AppColors.accent : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double strokeWidth;
  final bool glow;

  const _RingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4,
    this.glow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    const startAngle = -1.5707963267948966; // -π/2 (top)
    final sweepAngle = 2 * 3.141592653589793 * progress;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    if (glow) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      paint.maskFilter = null;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.glow != glow;
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SourceChip extends StatelessWidget {
  final bool running;
  final AppLocalizations l10n;
  const _SourceChip({required this.running, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (!running) return const SizedBox(height: 28);
    const color = AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.sourceGps,
            style: const TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final SettingsState settings;
  const _UnitToggle({required this.settings});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<SettingsCubit>().toggleUnit(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['km/h', 'mph'].map((unit) {
            final selected = settings.unitLabel == unit;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(
                unit,
                style: TextStyle(
                  color: selected ? AppColors.background : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  final String label;
  final String value;
  const _AlertBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accel.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accel.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_active_rounded,
              color: AppColors.accel, size: 14),
          const SizedBox(width: 6),
          Text(
            '$label  $value',
            style: const TextStyle(
              color: AppColors.accel,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
