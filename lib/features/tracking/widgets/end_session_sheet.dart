import 'package:flutter/material.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import '../../../core/models/activity_type.dart';
import '../../../core/models/session.dart';
import '../../../core/theme.dart';
import '../../settings/cubit/settings_state.dart';

class EndSessionSheet extends StatefulWidget {
  final Duration duration;
  final double topSpeedMs;
  final double avgSpeedMs;
  final List<double> speedSamples;
  final List<String> recentComments;
  final SettingsState settings;

  const EndSessionSheet({
    super.key,
    required this.duration,
    required this.topSpeedMs,
    required this.avgSpeedMs,
    required this.speedSamples,
    required this.recentComments,
    required this.settings,
  });

  @override
  State<EndSessionSheet> createState() => _EndSessionSheetState();
}

class _EndSessionSheetState extends State<EndSessionSheet> {
  final _controller = TextEditingController();
  ActivityType _selectedActivity = ActivityType.other;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _activityLabel(AppLocalizations l10n, ActivityType t) =>
      switch (t) {
        ActivityType.run   => l10n.activityRun,
        ActivityType.bike  => l10n.activityBike,
        ActivityType.ski   => l10n.activitySki,
        ActivityType.surf  => l10n.activitySurf,
        ActivityType.other => l10n.activityOther,
      };

  void _save() {
    final comment = _controller.text.trim();
    final now = DateTime.now();
    final session = Session(
      id: now.millisecondsSinceEpoch.toString(),
      startTime: now.subtract(widget.duration),
      endTime: now,
      topSpeedMs: widget.topSpeedMs,
      avgSpeedMs: widget.avgSpeedMs,
      activityType: _selectedActivity,
      speedSamples: widget.speedSamples,
      comment: comment.isEmpty ? null : comment,
    );
    Navigator.of(context).pop(session);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.sessionEnded,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(
                label: l10n.labelTopSpeed,
                value: widget.settings.formatSpeed(widget.topSpeedMs),
                unit: widget.settings.unitLabel,
                valueColor: AppColors.accent,
              ),
              const SizedBox(width: 10),
              _StatTile(
                label: l10n.labelAvgSpeed,
                value: widget.settings.formatSpeed(widget.avgSpeedMs),
                unit: widget.settings.unitLabel,
                valueColor: AppColors.white,
              ),
              const SizedBox(width: 10),
              _StatTile(
                label: l10n.labelDuration,
                value: _formatDuration(widget.duration),
                unit: '',
                valueColor: AppColors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.selectActivity,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ActivityType.values.map((type) {
                final selected = _selectedActivity == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedActivity = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          _activityLabel(l10n, type),
                          style: TextStyle(
                            color: selected ? AppColors.accent : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.addNote,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.white),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(hintText: l10n.noteHint),
          ),
          if (widget.recentComments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.recentComments.map((c) {
                return GestureDetector(
                  onTap: () => setState(() => _controller.text = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.btnDiscard,
                    style: const TextStyle(letterSpacing: 1.5, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.btnSave,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontSize: 15,
                    ),
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
