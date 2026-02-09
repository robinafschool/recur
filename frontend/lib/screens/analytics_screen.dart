import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../navigation/navigation.dart';
import '../utils/dream_stats.dart';
import '../view_models/journal_list_view_model.dart';
import '../widgets/widgets.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key, this.showNavBar = true});

  final bool showNavBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(journalListProvider);

    return GradientScaffold(
      bottomNavigationBar: showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.analytics,
              onTap: (index) =>
                  AppNavigator.navigateToIndex(context, NavIndex.analytics, index),
            )
          : null,
      child: RefreshIndicator(
        onRefresh: () => ref.read(journalListProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: asyncEntries.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing60),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing60),
                child: Text(
                  'Could not load your dreams. Pull to try again.',
                  style: AppTheme.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (entries) {
              final stats = DreamStats.fromEntries(entries);
              return _AnalyticsContent(stats: stats);
            },
          ),
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({required this.stats});

  final DreamStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GradientHeader(
          icon: Icons.insights,
          title: 'Dream Stats',
          description:
              'Your journal at a glance. More dreams and richer descriptions help you spot patterns and improve recall.',
        ),
        const SizedBox(height: AppTheme.spacing30),
        if (!stats.hasData) ...[
          _buildEmptyState(context),
        ] else ...[
          _buildMotivationBanner(context),
          const SizedBox(height: AppTheme.spacing20),
          _buildStatsGrid(),
          const SizedBox(height: AppTheme.spacing20),
          _buildDreamsPerDayChart(context),
          const SizedBox(height: AppTheme.spacing20),
          _buildDescriptivenessCard(context),
          const SizedBox(height: AppTheme.spacing20),
          _buildWeekComparison(context),
          const SizedBox(height: AppTheme.spacing20),
          _buildTipsCard(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing60,
          horizontal: AppTheme.spacing30,
        ),
        child: Column(
          children: [
            Icon(
              Icons.nightlight_round,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacing20),
            Text(
              'No dreams recorded yet',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing10),
            Text(
              'Record your first dream to see your stats here. The more you write, the more you\'ll discover about your sleep and recall.',
              style: AppTheme.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.journalEntry),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Record a dream'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing30,
                  vertical: AppTheme.spacing16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationBanner(BuildContext context) {
    String message;
    if (stats.totalDreams == 1) {
      message = 'You\'ve recorded your first dream. Add another to start seeing patterns.';
    } else if (stats.totalDreams < 5) {
      message = '${stats.totalDreams} dreams so far. Keep going — consistency builds recall.';
    } else if (stats.totalDreams < 20) {
      message = '${stats.totalDreams} dreams. You\'re building a real journal.';
    } else {
      message = '${stats.totalDreams} dreams recorded. Your future self will thank you.';
    }

    return AppCard(
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 28),
          const SizedBox(width: AppTheme.spacing15),
          Expanded(
            child: Text(
              message,
              style: AppTheme.body.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${stats.totalDreams}',
            label: 'Total dreams',
          ),
        ),
        const SizedBox(width: AppTheme.spacing15),
        Expanded(
          child: _StatCard(
            value: '${stats.recordingDays}',
            label: 'Days recorded',
          ),
        ),
      ],
    );
  }

  Widget _buildDreamsPerDayChart(BuildContext context) {
    final labels = stats.last7DayLabels;
    final values = stats.dreamsPerDayLast7;
    final maxY = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).clamp(1, 999).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dreams in the last 7 days', style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing15),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: _LineChartPainter(
                    values: values.map((v) => v.toDouble()).toList(),
                    maxY: maxY,
                    lineColor: AppTheme.primaryColor,
                    fillColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (i) {
              final count = i < values.length ? values[i] : 0;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      i < labels.length ? labels[i] : '',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptivenessCard(BuildContext context) {
    final avg = stats.avgWordsPerDream.round();
    String feedback;
    if (avg == 0) {
      feedback = 'Add more detail to your entries — it helps with recall and patterns.';
    } else if (avg < 30) {
      feedback = 'Try writing a bit more each time. Detail strengthens dream memory.';
    } else if (avg < 80) {
      feedback = 'Good detail. Richer entries make patterns easier to spot.';
    } else {
      feedback = 'Your entries are rich and detailed. Keep it up.';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: AppTheme.primaryColor, size: 22),
              const SizedBox(width: AppTheme.spacing8),
              Text('Descriptiveness', style: AppTheme.heading2),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            avg > 0 ? '~$avg words per dream on average' : 'No words to average yet',
            style: AppTheme.bodySecondary,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            feedback,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekComparison(BuildContext context) {
    final diff = stats.dreamsThisWeek - stats.dreamsLastWeek;
    String weekMessage;
    if (stats.dreamsLastWeek == 0 && stats.dreamsThisWeek == 0) {
      weekMessage = 'Record dreams this week to see your weekly trend.';
    } else if (stats.dreamsLastWeek == 0) {
      weekMessage = '${stats.dreamsThisWeek} dream${stats.dreamsThisWeek == 1 ? '' : 's'} this week so far.';
    } else if (diff > 0) {
      weekMessage = '${stats.dreamsThisWeek} this week vs ${stats.dreamsLastWeek} last week — you\'re recording more.';
    } else if (diff < 0) {
      weekMessage = '${stats.dreamsThisWeek} this week. Last week you had ${stats.dreamsLastWeek} — add one more to keep the habit.';
    } else {
      weekMessage = 'Same as last week (${stats.dreamsThisWeek} dreams). One more would be a step up.';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            weekMessage,
            style: AppTheme.bodySecondary,
          ),
          if (stats.currentStreak > 0) ...[
            const SizedBox(height: AppTheme.spacing15),
            Row(
              children: [
                Icon(Icons.local_fire_department, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  '${stats.currentStreak}-day recording streak',
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: AppTheme.spacing8),
              Text('Tips', style: AppTheme.heading2),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            '• Record as soon as you wake — details fade fast.\n'
            '• Write what you felt and saw, not just events.\n'
            '• More entries and more detail make patterns and lucidity easier to spot.',
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.maxY,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> values;
  final double maxY;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    const padding = 8.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final stepX = chartWidth / (values.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = padding + i * stepX;
      final yNorm = maxY > 0 ? values[i] / maxY : 0.0;
      final y = padding + chartHeight * (1 - yNorm);
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height - padding)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, size.height - padding);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()..color = fillColor,
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final p in points) {
      canvas.drawCircle(
        p,
        4,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.values != values || old.maxY != maxY;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeDisplay,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTheme.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

