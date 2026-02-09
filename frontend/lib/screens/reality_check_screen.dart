import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../navigation/navigation.dart';
import '../view_models/reality_check_schedule_view_model.dart';
import '../widgets/widgets.dart';

class RealityCheckScreen extends ConsumerWidget {
  const RealityCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing20,
                AppTheme.spacing20,
                AppTheme.spacing20,
                AppTheme.spacing10,
              ),
              child: ScreenHeader(
                title: 'Reality checks',
                onSettingsTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ),
            const SizedBox(height: AppTheme.spacing10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
              child: Text(
                'One daily schedule. Set your window and interval — reminders help you question reality and boost lucid dreaming.',
                style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(realityCheckScheduleProvider.notifier).refresh(),
                child: const RealityCheckScheduleView(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: NavIndex.schedule,
        onTap: (index) => AppNavigator.navigateToIndex(context, NavIndex.schedule, index),
      ),
    );
  }
}
