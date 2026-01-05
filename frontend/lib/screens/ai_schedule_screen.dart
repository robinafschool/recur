import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../models/models.dart';

class AiScheduleScreen extends StatefulWidget {
  final bool showNavBar;

  const AiScheduleScreen({super.key, this.showNavBar = true});

  @override
  State<AiScheduleScreen> createState() => _AiScheduleScreenState();
}

class _AiScheduleScreenState extends State<AiScheduleScreen> {
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

  Future<void> _editRealityCheck(RealityCheck rc) async {
    final nameController = TextEditingController(text: rc.name);
    final intervalController = TextEditingController(
      text: rc.type == 'interval' ? rc.intervalMinutes.toString() : '',
    );
    final eventController = TextEditingController(
      text: rc.type == 'event' ? (rc.eventDescription ?? '') : '',
    );
    String? selectedType = rc.type;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'interval', child: Text('Interval')),
                    DropdownMenuItem(value: 'event', child: Text('Event-based')),
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
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }

                if (selectedType == 'interval' && intervalController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter interval minutes')),
                  );
                  return;
                }

                if (selectedType == 'event' && eventController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter event description')),
                  );
                  return;
                }

                await _updateRealityCheck(
                  rc: rc,
                  name: nameController.text,
                  type: selectedType!,
                  intervalMinutes: selectedType == 'interval'
                      ? int.tryParse(intervalController.text)
                      : null,
                  eventDescription: selectedType == 'event' ? eventController.text : null,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRealityCheck({
    required RealityCheck rc,
    required String name,
    required String type,
    int? intervalMinutes,
    String? eventDescription,
  }) async {
    try {
      await Supabase.instance.client
          .from('reality_checks')
          .update({
            'name': name,
            'type': type,
            'interval_minutes': intervalMinutes,
            'event_description': eventDescription,
          })
          .eq('id', rc.id);

      await _loadRealityChecks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reality check: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(RealityCheck realityCheck) async {
    try {
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

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: widget.showNavBar
          ? BottomNavBar(
              currentIndex: NavIndex.aiSchedule,
              onTap: _navigateToScreen,
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRealityChecksList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRealityChecksList() {
    if (_realityChecks.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing60),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: AppTheme.spacing15),
              Text(
                'No reality checks yet',
                style: AppTheme.heading2,
              ),
              const SizedBox(height: AppTheme.spacing10),
              Text(
                'Create reality checks in the Reality Checks screen to manage them here',
                style: AppTheme.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.habits);
                },
                child: const Text('Go to Reality Checks'),
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
          const Text('Your Reality Checks', style: AppTheme.heading2),
          const SizedBox(height: AppTheme.spacing15),
          ..._realityChecks.map((rc) => _buildRealityCheckItem(rc)),
        ],
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
                    Text(
                      rc.name,
                      style: AppTheme.heading2,
                    ),
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
                onPressed: () => _toggleActive(rc),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing10),
          Text(
            scheduleText,
            style: AppTheme.bodySecondary,
          ),
          const SizedBox(height: AppTheme.spacing10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _editRealityCheck(rc),
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
