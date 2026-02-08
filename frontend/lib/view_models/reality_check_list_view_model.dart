import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reality_check.dart';
import '../providers/providers.dart';

class RealityCheckListNotifier extends AsyncNotifier<List<RealityCheck>> {
  @override
  Future<List<RealityCheck>> build() async {
    final repo = ref.watch(realityCheckRepositoryProvider);
    return repo.getRealityChecksForCurrentUser();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(realityCheckRepositoryProvider);
      return repo.getRealityChecksForCurrentUser();
    });
  }

  Future<void> create({
    required String name,
    required String type,
    int? intervalMinutes,
    String? eventDescription,
  }) async {
    final repo = ref.read(realityCheckRepositoryProvider);
    await repo.create(
      name: name,
      type: type,
      intervalMinutes: intervalMinutes,
      eventDescription: eventDescription,
    );
    await refresh();
  }

  Future<void> updateRealityCheck({
    required RealityCheck rc,
    required String name,
    required String type,
    int? intervalMinutes,
    String? eventDescription,
  }) async {
    final repo = ref.read(realityCheckRepositoryProvider);
    await repo.update(
      id: rc.id,
      name: name,
      type: type,
      intervalMinutes: intervalMinutes,
      eventDescription: eventDescription,
    );
    await refresh();
  }

  Future<void> setActive(RealityCheck rc, bool isActive) async {
    final repo = ref.read(realityCheckRepositoryProvider);
    await repo.setActive(rc.id, isActive);
    await refresh();
  }

  Future<void> delete(RealityCheck rc) async {
    final repo = ref.read(realityCheckRepositoryProvider);
    await repo.delete(rc.id);
    await refresh();
  }
}

final realityCheckListProvider =
    AsyncNotifierProvider<RealityCheckListNotifier, List<RealityCheck>>(
  RealityCheckListNotifier.new,
);
