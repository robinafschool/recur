import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/reality_check_schedule.dart';
import '../view_models/reality_check_schedule_view_model.dart';
import 'widgets.dart';

/// Shared schedule UI: floating tile (toggle + day chart) and range slider for start/end.
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
        child: _ScheduleTile(schedule: schedule, notifier: notifier),
      ),
    );
  }
}

/// End of day as slider value (23:30).
const double _maxHours = 23.5;
const double _thumbRadius = 6.0;
/// Minimum range size (one 30-minute step).
const double _minRangeHours = 0.5;
/// Inset so trigger dots stay inside the draggable range (smaller visual range).
const double _pointInset = 8.0;

/// Floating tile: toggle + title, then slider-as-chart with live-updating trigger dots.
class _ScheduleTile extends StatefulWidget {
  const _ScheduleTile({required this.schedule, required this.notifier});

  final RealityCheckSchedule schedule;
  final RealityCheckScheduleNotifier notifier;

  @override
  State<_ScheduleTile> createState() => _ScheduleTileState();
}

class _ScheduleTileState extends State<_ScheduleTile> {
  static double _timeToHours(String time) {
    final parts = time.split(':');
    if (parts.isEmpty) return 8.0;
    final h = int.tryParse(parts[0]) ?? 8;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    if (h == 24 && m == 0) return _maxHours;
    if (h == 23 && m >= 30) return _maxHours;
    return (h + m / 60.0).clamp(0.0, _maxHours);
  }

  static String _hoursToTime(double hours) {
    if (hours >= _maxHours) return '23:30';
    hours = hours.clamp(0.0, _maxHours);
    final totalM = (hours * 60).round();
    final h = (totalM ~/ 60) % 24;
    final m = totalM % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static RangeValues _normalize(RangeValues v) {
    var start = v.start.clamp(0.0, _maxHours);
    var end = v.end.clamp(0.0, _maxHours);
    if (start > end) {
      final t = start;
      start = end;
      end = t;
    }
    if (end - start < _minRangeHours) {
      if (end + _minRangeHours <= _maxHours) {
        end = start + _minRangeHours;
      } else if (start - _minRangeHours >= 0) {
        start = end - _minRangeHours;
      } else {
        start = 0;
        end = _minRangeHours.clamp(0.0, _maxHours);
      }
    }
    return RangeValues(start, end);
  }

  /// Trigger positions (0..1) for the current range and interval, matching slider scale.
  static List<double> _triggerPositions(
    double startHours,
    double endHours,
    int intervalMinutes,
  ) {
    if (intervalMinutes <= 0) return [];
    var startM = startHours * 60;
    var endM = endHours * 60;
    if (endM <= startM) endM += 24 * 60;
    final positions = <double>[];
    for (var m = startM; m <= endM; m += intervalMinutes) {
      final h = m / 60;
      positions.add((h / _maxHours).clamp(0.0, 1.0));
    }
    return positions;
  }

  late RangeValues _values;

  @override
  void initState() {
    super.initState();
    _values = _normalize(
      RangeValues(
        _timeToHours(widget.schedule.startTime),
        _timeToHours(widget.schedule.endTime),
      ),
    );
  }

  @override
  void didUpdateWidget(_ScheduleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule.startTime != widget.schedule.startTime ||
        oldWidget.schedule.endTime != widget.schedule.endTime) {
      _values = _normalize(
        RangeValues(
          _timeToHours(widget.schedule.startTime),
          _timeToHours(widget.schedule.endTime),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;
    final notifier = widget.notifier;
    final pointColor = schedule.enabled
        ? AppTheme.primaryColor
        : AppTheme.textTertiary;
    final triggerPositions = _triggerPositions(
      _values.start,
      _values.end,
      schedule.intervalMinutes,
    );

    return AppCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reality check reminders',
                          style: AppTheme.heading2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.enabled
                              ? 'On — ${_hoursToTime(_values.start)} – ${_hoursToTime(_values.end)}'
                              : 'Off',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ToggleSwitch(
                    value: schedule.enabled,
                    onChanged: (v) =>
                        _save(notifier, schedule.copyWith(enabled: v), context),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return SizedBox(
                    height: 44,
                    width: w,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            rangeThumbShape: RoundRangeSliderThumbShape(
                              enabledThumbRadius: _thumbRadius,
                              elevation: 0,
                              pressedElevation: 0,
                            ),
                            rangeTrackShape:
                                const RoundedRectRangeSliderTrackShape(),
                            activeTrackColor: schedule.enabled
                                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                                : AppTheme.textTertiary.withValues(alpha: 0.3),
                            inactiveTrackColor: schedule.enabled
                                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                : AppTheme.dividerColor,
                            thumbColor: AppTheme.primaryColor,
                            overlayColor: AppTheme.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: RangeSlider(
                            values: _values,
                            min: 0,
                            max: _maxHours,
                            divisions: 24 * 2 - 1,
                            onChanged: schedule.enabled
                                ? (v) => setState(() => _values = _normalize(v))
                                : null,
                            onChangeEnd: (v) {
                              final n = _normalize(v);
                              final start = _hoursToTime(n.start);
                              final end = _hoursToTime(n.end);
                              _save(
                                notifier,
                                schedule.copyWith(
                                  startTime: start,
                                  endTime: end,
                                ),
                                context,
                              );
                            },
                          ),
                        ),
                        // Trigger dots (live-updating), aligned to slider track
                        IgnorePointer(
                          child: Center(
                            child: SizedBox(
                              height: 44,
                              width: w,
                              child: CustomPaint(
                                painter: _TriggerDotsPainter(
                                  positions: triggerPositions,
                                  color: pointColor,
                                  trackWidth: w,
                                  thumbRadius: _thumbRadius,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0:00',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '23:30',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing20),
              Center(
                child: _IntervalWheel(
                  schedule: schedule,
                  notifier: notifier,
                ),
              ),
            ],
          ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }
}

class _TriggerDotsPainter extends CustomPainter {
  _TriggerDotsPainter({
    required this.positions,
    required this.color,
    required this.trackWidth,
    this.thumbRadius,
  });

  final List<double> positions;
  final Color color;
  final double trackWidth;
  final double? thumbRadius;

  double get _effectiveThumbRadius => thumbRadius ?? _thumbRadius;

  @override
  void paint(Canvas canvas, Size size) {
    const dotRadius = 6.0;
    final centerY = size.height * 0.5;
    final r = _effectiveThumbRadius;
    final trackLen = trackWidth - 2 * r;
    final pointsLen = (trackLen - 2 * _pointInset).clamp(1.0, double.infinity);
    final leftEdge = r + _pointInset;
    for (final t in positions) {
      final x = leftEdge + (t.clamp(0.0, 1.0) * pointsLen);
      final glow = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, centerY), dotRadius, glow);
      final fill = Paint()..color = color;
      canvas.drawCircle(Offset(x, centerY), dotRadius, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _TriggerDotsPainter oldDelegate) {
    if (oldDelegate._effectiveThumbRadius != _effectiveThumbRadius) return true;
    if (oldDelegate.color != color || oldDelegate.trackWidth != trackWidth)
      return true;
    if (oldDelegate.positions.length != positions.length) return true;
    for (var i = 0; i < positions.length; i++) {
      if (oldDelegate.positions[i] != positions[i]) return true;
    }
    return false;
  }
}

/// Interval selector: "Every <n> hours" with a vertical wheel (alarm-clock style).
class _IntervalWheel extends StatefulWidget {
  const _IntervalWheel({required this.schedule, required this.notifier});

  final RealityCheckSchedule schedule;
  final RealityCheckScheduleNotifier notifier;

  static const List<int> _hours = [1, 2, 3, 4, 5, 6];
  static const double _itemExtent = 44.0;
  static const double _wheelHeight = 110.0;

  @override
  State<_IntervalWheel> createState() => _IntervalWheelState();
}

class _IntervalWheelState extends State<_IntervalWheel> {
  late FixedExtentScrollController _controller;
  Timer? _saveTimer;
  bool _isScrollingFromUser = false;

  int get _currentIndex {
    final h = (widget.schedule.intervalMinutes / 60).round().clamp(1, 6);
    final i = _IntervalWheel._hours.indexOf(h);
    return i >= 0 ? i : 0;
  }

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: _currentIndex.clamp(0, _IntervalWheel._hours.length - 1),
    );
  }

  @override
  void didUpdateWidget(_IntervalWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isScrollingFromUser) return;
    if (oldWidget.schedule.intervalMinutes != widget.schedule.intervalMinutes) {
      final i = _currentIndex.clamp(0, _IntervalWheel._hours.length - 1);
      if (_controller.hasClients && _controller.selectedItem != i) {
        _controller.jumpToItem(i);
      }
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleSave(int index) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () {
      _saveTimer = null;
      _isScrollingFromUser = false;
      if (!mounted || !_controller.hasClients) return;
      final i = _controller.selectedItem.clamp(0, _IntervalWheel._hours.length - 1);
      final minutes = _IntervalWheel._hours[i] * 60;
      _save(
        widget.notifier,
        widget.schedule.copyWith(intervalMinutes: minutes),
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.schedule.enabled;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Every ',
            style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
          ),
          IgnorePointer(
            ignoring: !enabled,
            child: SizedBox(
              height: _IntervalWheel._wheelHeight,
              width: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: _IntervalWheel._itemExtent,
                    diameterRatio: 1.2,
                    perspective: 0.003,
                    physics: enabled
                        ? const FixedExtentScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    onSelectedItemChanged: enabled
                        ? (index) {
                            if (index >= 0 &&
                                index < _IntervalWheel._hours.length) {
                              _isScrollingFromUser = true;
                              _scheduleSave(index);
                            }
                          }
                        : null,
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= _IntervalWheel._hours.length) {
                      return const SizedBox.shrink();
                    }
                    return Center(
                      child: Text(
                        '${_IntervalWheel._hours[index]}',
                        style: AppTheme.heading1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    );
                  },
                  childCount: _IntervalWheel._hours.length,
                ),
              ),
              IgnorePointer(
                child: Container(
                  height: _IntervalWheel._itemExtent,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.dividerColor,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: AppTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
        const SizedBox(width: 4),
        Text(
          'hours',
          style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
        ),
      ],
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
}
