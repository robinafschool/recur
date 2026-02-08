import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';
import '../view_models/reality_check_list_view_model.dart';

class RealityCheckScreen extends ConsumerWidget {
  const RealityCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(realityCheckListProvider);
    final notifier = ref.read(realityCheckListProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: 'Reality Checks',
                onSettingsTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const SizedBox(height: AppTheme.spacing10),
              const Text(
                'Reality checks help you recognize when you\'re dreaming. Practice them regularly to increase your chances of lucid dreaming.',
                style: AppTheme.caption,
              ),
              const SizedBox(height: AppTheme.spacing30),
              Expanded(
                child: asyncList.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text('Error: $err', style: AppTheme.bodySecondary),
                  ),
                  data: (list) => _RealityChecksList(
                    realityChecks: list,
                    onToggle: (rc) => notifier.setActive(rc, !rc.isActive),
                    onDelete: (rc) => _confirmDelete(context, ref, rc),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),
              ElevatedButton(
                onPressed: () => _showCreateRealityCheckDialog(context, ref),
                child: const Text('Create Reality Check'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: NavIndex.aiSchedule,
        onTap: (index) => AppNavigator.navigateToIndex(context, NavIndex.aiSchedule, index),
      ),
    );
  }

  static Future<void> _confirmDelete(BuildContext context, WidgetRef ref, RealityCheck rc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reality Check'),
        content: Text('Are you sure you want to delete "${rc.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(realityCheckListProvider.notifier).delete(rc);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
      }
    }
  }

  static Future<void> _showCreateRealityCheckDialog(BuildContext context, WidgetRef ref) async {
    String? selectedType;
    final nameController = TextEditingController();
    final intervalController = TextEditingController();
    final eventController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Reality Check'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Check hands, Count fingers',
                  ),
                ),
                const SizedBox(height: AppTheme.spacing20),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'interval', child: Text('Interval')),
                    DropdownMenuItem(value: 'event', child: Text('Event-based')),
                  ],
                  onChanged: (value) => setDialogState(() => selectedType = value),
                ),
                if (selectedType == 'interval') ...[
                  const SizedBox(height: AppTheme.spacing20),
                  TextField(
                    controller: intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Interval (minutes)',
                      hintText: 'e.g., 120 for every 2 hours',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                if (selectedType == 'event') ...[
                  const SizedBox(height: AppTheme.spacing20),
                  TextField(
                    controller: eventController,
                    decoration: const InputDecoration(
                      labelText: 'Event Description',
                      hintText: 'e.g., when you see your pet',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedType == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                if (selectedType == 'interval' && intervalController.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter interval minutes')),
                  );
                  return;
                }
                if (selectedType == 'event' && eventController.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter event description')),
                  );
                  return;
                }
                try {
                  await ref.read(realityCheckListProvider.notifier).create(
                        name: nameController.text,
                        type: selectedType!,
                        intervalMinutes: selectedType == 'interval'
                            ? int.tryParse(intervalController.text)
                            : null,
                        eventDescription: selectedType == 'event' ? eventController.text : null,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error creating: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealityChecksList extends StatelessWidget {
  const _RealityChecksList({
    required this.realityChecks,
    required this.onToggle,
    required this.onDelete,
  });

  final List<RealityCheck> realityChecks;
  final void Function(RealityCheck) onToggle;
  final void Function(RealityCheck) onDelete;

  @override
  Widget build(BuildContext context) {
    if (realityChecks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: AppTheme.spacing20),
            Text('No reality checks yet', style: AppTheme.bodySecondary),
            const SizedBox(height: AppTheme.spacing10),
            Text(
              'Create your first reality check to start training for lucid dreams',
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AppCard(
      constraints: const BoxConstraints(minHeight: 400),
      child: ListView(
        children: realityChecks.map((rc) => _RealityCheckItem(rc: rc, onToggle: onToggle, onDelete: onDelete)).toList(),
      ),
    );
  }
}

class _RealityCheckItem extends StatelessWidget {
  const _RealityCheckItem({
    required this.rc,
    required this.onToggle,
    required this.onDelete,
  });

  final RealityCheck rc;
  final void Function(RealityCheck) onToggle;
  final void Function(RealityCheck) onDelete;

  @override
  Widget build(BuildContext context) {
    final scheduleText = rc.type == 'interval'
        ? 'Every ${rc.intervalMinutes} minutes'
        : 'When you see: ${rc.eventDescription}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing15),
      padding: const EdgeInsets.all(AppTheme.spacing15),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: rc.isActive ? AppTheme.primaryColor : AppTheme.dividerColor,
          width: rc.isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rc.name, style: AppTheme.heading2),
                    const SizedBox(height: AppTheme.spacing8),
                    Row(
                      children: [
                        TagChip(
                          label: rc.type == 'interval' ? 'Interval' : 'Event',
                          backgroundColor: rc.type == 'interval'
                              ? AppTheme.primaryColor.withValues(alpha: 0.2)
                              : AppTheme.successColor.withValues(alpha: 0.2),
                          textColor: rc.type == 'interval' ? AppTheme.primaryColor : AppTheme.successColor,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        if (!rc.isActive)
                          TagChip(
                            label: 'Inactive',
                            backgroundColor: AppTheme.textTertiary.withValues(alpha: 0.2),
                            textColor: AppTheme.textTertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  rc.isActive ? Icons.toggle_on : Icons.toggle_off,
                  color: rc.isActive ? AppTheme.primaryColor : AppTheme.textTertiary,
                  size: 32,
                ),
                onPressed: () => onToggle(rc),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing10),
          Text(scheduleText, style: AppTheme.bodySecondary),
          const SizedBox(height: AppTheme.spacing10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => onDelete(rc),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
