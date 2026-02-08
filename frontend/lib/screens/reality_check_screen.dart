import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

class RealityCheckScreen extends StatefulWidget {
  const RealityCheckScreen({super.key});

  @override
  State<RealityCheckScreen> createState() => _RealityCheckScreenState();
}

class _RealityCheckScreenState extends State<RealityCheckScreen> {
  List<RealityCheck> _realityChecks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealityChecks();
  }

  Future<void> _loadRealityChecks() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('reality_checks')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _realityChecks = (response as List)
            .map((json) => RealityCheck.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading reality checks: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.aiSchedule, index);
  }

  Future<void> _showCreateRealityCheckDialog() async {
    String? selectedType;
    final nameController = TextEditingController();
    final intervalController = TextEditingController();
    final eventController = TextEditingController();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'interval',
                      child: Text('Interval'),
                    ),
                    DropdownMenuItem(
                      value: 'event',
                      child: Text('Event-based'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedType = value);
                  },
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                    ),
                  );
                  return;
                }

                if (selectedType == 'interval' &&
                    intervalController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter interval minutes'),
                    ),
                  );
                  return;
                }

                if (selectedType == 'event' && eventController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter event description'),
                    ),
                  );
                  return;
                }

                await _createRealityCheck(
                  name: nameController.text,
                  type: selectedType!,
                  intervalMinutes: selectedType == 'interval'
                      ? int.tryParse(intervalController.text)
                      : null,
                  eventDescription: selectedType == 'event'
                      ? eventController.text
                      : null,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createRealityCheck({
    required String name,
    required String type,
    int? intervalMinutes,
    String? eventDescription,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('reality_checks').insert({
        'user_id': user.id,
        'name': name,
        'type': type,
        'interval_minutes': intervalMinutes,
        'event_description': eventDescription,
        'is_active': true,
      });

      await _loadRealityChecks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating reality check: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(RealityCheck realityCheck) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('reality_checks')
          .update({'is_active': !realityCheck.isActive})
          .eq('id', realityCheck.id);

      await _loadRealityChecks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reality check: $e')),
        );
      }
    }
  }

  Future<void> _deleteRealityCheck(RealityCheck realityCheck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reality Check'),
        content: Text(
          'Are you sure you want to delete "${realityCheck.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client
          .from('reality_checks')
          .delete()
          .eq('id', realityCheck.id);

      await _loadRealityChecks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting reality check: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: 'Reality Checks',
                onSettingsTap: () =>
                    Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const SizedBox(height: AppTheme.spacing10),
              const Text(
                'Reality checks help you recognize when you\'re dreaming. Practice them regularly to increase your chances of lucid dreaming.',
                style: AppTheme.caption,
              ),
              const SizedBox(height: AppTheme.spacing30),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildRealityChecksList(),
              ),
              const SizedBox(height: AppTheme.spacing20),
              ElevatedButton(
                onPressed: _showCreateRealityCheckDialog,
                child: const Text('Create Reality Check'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: NavIndex.aiSchedule,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildRealityChecksList() {
    if (_realityChecks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.textTertiary,
            ),
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
        children: _realityChecks
            .map((rc) => _buildRealityCheckItem(rc))
            .toList(),
      ),
    );
  }

  Widget _buildRealityCheckItem(RealityCheck rc) {
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
                          textColor: rc.type == 'interval'
                              ? AppTheme.primaryColor
                              : AppTheme.successColor,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        if (!rc.isActive)
                          TagChip(
                            label: 'Inactive',
                            backgroundColor: AppTheme.textTertiary.withValues(
                              alpha: 0.2,
                            ),
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
                  color: rc.isActive
                      ? AppTheme.primaryColor
                      : AppTheme.textTertiary,
                  size: 32,
                ),
                onPressed: () => _toggleActive(rc),
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
                onPressed: () => _deleteRealityCheck(rc),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
