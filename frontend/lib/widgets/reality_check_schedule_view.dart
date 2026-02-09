import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/reality_check_schedule.dart';
import '../view_models/reality_check_schedule_view_model.dart';
import 'widgets.dart';

/// Shared schedule UI: one enable/disable schedule with interval and start/end window.
class RealityCheckScheduleView extends ConsumerWidget {
  const RealityCheckScheduleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSchedule = ref.watch(realityCheckScheduleProvider);
    final notifier = ref.read(realityCheckScheduleProvider.notifier);

    return asyncSchedule.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => SizedBox(
          height: 200,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Text(
                'Could not load schedule. Pull to retry.',
                style: AppTheme.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        data: (schedule) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEnableCard(context, schedule, notifier),
            const SizedBox(height: AppTheme.spacing20),
            _buildWindowCard(context, schedule, notifier),
            const SizedBox(height: AppTheme.spacing20),
            _buildIntervalCard(context, schedule, notifier),
            const SizedBox(height: AppTheme.spacing20),
              _buildTimelineCard(schedule),
            ],
          ),
        ),
    );
  }

  Widget _buildEnableCard(
    BuildContext context,
    RealityCheckSchedule schedule,
    RealityCheckScheduleNotifier notifier,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: schedule.enabled
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                schedule.enabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                size: 28,
                color: schedule.enabled ? AppTheme.primaryColor : AppTheme.textTertiary,
              ),
            ),
            const SizedBox(width: AppTheme.spacing20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reality check reminders',
                    style: AppTheme.heading2.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.enabled ? 'On — you\'ll be reminded in your window' : 'Off',
                    style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            ToggleSwitch(
              value: schedule.enabled,
              onChanged: (v) => _save(notifier, schedule.copyWith(enabled: v), context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowCard(
    BuildContext context,
    RealityCheckSchedule schedule,
    RealityCheckScheduleNotifier notifier,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, size: 22, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacing8),
                Text('Daily window', style: AppTheme.heading2),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'Reminders only between start and end time.',
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacing20),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    label: 'Start',
                    value: schedule.startTime,
                    onTap: () => _pickTime(context, schedule.startTime, (t) {
                      _save(notifier, schedule.copyWith(startTime: t), context);
                    }),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing15),
                Expanded(
                  child: _TimeChip(
                    label: 'End',
                    value: schedule.endTime,
                    onTap: () => _pickTime(context, schedule.endTime, (t) {
                      _save(notifier, schedule.copyWith(endTime: t), context);
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalCard(
    BuildContext context,
    RealityCheckSchedule schedule,
    RealityCheckScheduleNotifier notifier,
  ) {
    const options = [
      (60, '1h'),
      (120, '2h'),
      (180, '3h'),
      (240, '4h'),
      (360, '6h'),
    ];
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 22, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacing8),
                Text('Interval', style: AppTheme.heading2),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'How often to remind you within the window.',
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacing15),
            Wrap(
              spacing: AppTheme.spacing10,
              runSpacing: AppTheme.spacing10,
              children: options.map((opt) {
                final selected = schedule.intervalMinutes == opt.$1;
                return GestureDetector(
                  onTap: () => _save(
                    notifier,
                    schedule.copyWith(intervalMinutes: opt.$1),
                    context,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing20,
                      vertical: AppTheme.spacing12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryColor
                          : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryColor
                            : AppTheme.dividerColor,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      'Every ${opt.$2}',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(RealityCheckSchedule schedule) {
    final hours = schedule.triggerHours;
    final labels = hours.map((h) => '${h.toString().padLeft(2, '0')}:00').toList();

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 22, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacing8),
                Text('Reminders today', style: AppTheme.heading2),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            if (hours.isEmpty)
              Text(
                'Adjust start, end or interval to see times.',
                style: AppTheme.bodySecondary,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(hours.length * 2 - 1, (i) {
                        if (i.isOdd) {
                          return Container(
                            width: 12,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Center(
                              child: Container(
                                width: 4,
                                height: 2,
                                color: AppTheme.dividerColor,
                              ),
                            ),
                          );
                        }
                        final idx = i ~/ 2;
                        final timeLabel = labels[idx];
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                            vertical: AppTheme.spacing12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeMedium,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    RealityCheckScheduleNotifier notifier,
    RealityCheckSchedule schedule,
    BuildContext context,
  ) async {
    try {
      await notifier.saveSchedule(schedule);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    String current,
    void Function(String) onPicked,
  ) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null && context.mounted) {
      onPicked('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing16,
          ),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.caption),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
