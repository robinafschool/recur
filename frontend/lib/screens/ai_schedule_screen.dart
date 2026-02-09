import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../navigation/navigation.dart';
import '../view_models/reality_check_schedule_view_model.dart';
import '../widgets/widgets.dart';

/// Single schedule screen (reality check reminders). Uses the same page template
/// as analytics and journal list: GradientScaffold + padded SingleChildScrollView.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key, this.showNavBar = true});

  final bool showNavBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      bottomNavigationBar: showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.schedule,
              onTap: (index) =>
                  AppNavigator.navigateToIndex(context, NavIndex.schedule, index),
            )
          : null,
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(realityCheckScheduleProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GradientHeader(
                icon: Icons.schedule,
                title: 'Reality Check Schedule',
                description:
                    'One daily window and interval. Your reminder times appear below.',
              ),
              const SizedBox(height: AppTheme.spacing30),
              const RealityCheckScheduleView(),
            ],
          ),
        ),
      ),
    );
  }
}
