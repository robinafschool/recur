import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reality_check_schedule.dart';
import '../providers/providers.dart';

class RealityCheckScheduleNotifier extends AsyncNotifier<RealityCheckSchedule> {
  @override
  Future<RealityCheckSchedule> build() async {
    final repo = ref.watch(realityCheckRepositoryProvider);
    return repo.getScheduleForCurrentUser();
  }

  Future<void> saveSchedule(RealityCheckSchedule schedule) async {
    final repo = ref.read(realityCheckRepositoryProvider);
    await repo.saveSchedule(schedule);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(realityCheckRepositoryProvider);
      return repo.getScheduleForCurrentUser();
    });
  }
}

final realityCheckScheduleProvider =
    AsyncNotifierProvider<RealityCheckScheduleNotifier, RealityCheckSchedule>(
  RealityCheckScheduleNotifier.new,
);
