import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';
import '../view_models/reality_check_list_view_model.dart';

class AiScheduleScreen extends ConsumerWidget {
  const AiScheduleScreen({super.key, this.showNavBar = true});

  final bool showNavBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(realityCheckListProvider);
    final notifier = ref.read(realityCheckListProvider.notifier);

    return GradientScaffold(
      bottomNavigationBar: showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.aiSchedule,
              onTap: (index) => AppNavigator.navigateToIndex(context, NavIndex.aiSchedule, index),
            )
          : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GradientHeader(
              icon: Icons.schedule,
              title: 'Reality Check Schedule',
              description:
                  'Manage your reality checks and their schedules. Edit, enable, or disable them as needed.',
            ),
            const SizedBox(height: AppTheme.spacing30),
            asyncList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error: $err', style: AppTheme.bodySecondary),
              ),
              data: (list) => _ScheduleList(
                realityChecks: list,
                onEdit: (rc) => _showEditDialog(context, ref, rc),
                onToggle: (rc) => notifier.setActive(rc, !rc.isActive),
                onDelete: (rc) => _confirmDelete(context, ref, rc),
                onCreate: () => _showCreateDialog(context, ref),
              ),
            ),
          ],
        ),
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
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

  static Future<void> _showEditDialog(BuildContext context, WidgetRef ref, RealityCheck rc) async {
    final nameController = TextEditingController(text: rc.name);
    final intervalController = TextEditingController(
      text: rc.type == 'interval' ? rc.intervalMinutes.toString() : '',
    );
    final eventController = TextEditingController(
      text: rc.type == 'event' ? (rc.eventDescription ?? '') : '',
    );
    String? selectedType = rc.type;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Reality Check'),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
                  await ref.read(realityCheckListProvider.notifier).updateRealityCheck(
                        rc: rc,
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
                      SnackBar(content: Text('Error updating: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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

class _ScheduleList extends StatelessWidget {
  const _ScheduleList({
    required this.realityChecks,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.onCreate,
  });

  final List<RealityCheck> realityChecks;
  final void Function(RealityCheck) onEdit;
  final void Function(RealityCheck) onToggle;
  final void Function(RealityCheck) onDelete;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    if (realityChecks.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing60),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: AppTheme.spacing15),
              Text('No reality checks yet', style: AppTheme.heading2),
              const SizedBox(height: AppTheme.spacing10),
              Text(
                'Create your first reality check to manage schedules here.',
                style: AppTheme.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing20),
              ElevatedButton(
                onPressed: onCreate,
                child: const Text('Create Reality Check'),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Your Reality Checks', style: AppTheme.heading2),
              TextButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing15),
          ...realityChecks.map(
            (rc) => _ScheduleItem(
              rc: rc,
              onEdit: () => onEdit(rc),
              onToggle: () => onToggle(rc),
              onDelete: () => onDelete(rc),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({
    required this.rc,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final RealityCheck rc;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

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
                onPressed: onToggle,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing10),
          Text(scheduleText, style: AppTheme.bodySecondary),
          const SizedBox(height: AppTheme.spacing10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onEdit, child: const Text('Edit')),
              TextButton(
                onPressed: onDelete,
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
