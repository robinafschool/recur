import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/gradient_header.dart';
import '../utils/route_generator.dart';
import 'analytics_screen.dart';
import 'journal_list_screen.dart';
import 'ai_schedule_screen.dart';
import 'settings_screen.dart';

class JournalEntryScreen extends StatefulWidget {
  final bool showNavBar;

  const JournalEntryScreen({super.key, this.showNavBar = true});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _entryController = TextEditingController();

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  static const int _currentIndex = 2; // Journal Entry is middle item

  void _navigateToScreen(int index) {
    if (index == _currentIndex)
      return; // Don't navigate if already on this screen

    final routes = [
      '/analytics',
      '/journal-list',
      '/journal-entry',
      '/ai-schedule',
      '/settings',
    ];
    final direction = getSlideDirection(_currentIndex, index);

    Navigator.pushReplacement(
      context,
      SlideRoute(page: _getRouteWidget(routes[index]), direction: direction),
    );
  }

  Widget _getRouteWidget(String route) {
    switch (route) {
      case '/analytics':
        return const AnalyticsScreen();
      case '/journal-list':
        return const JournalListScreen();
      case '/journal-entry':
        return const JournalEntryScreen();
      case '/ai-schedule':
        return const AiScheduleScreen();
      case '/settings':
        return const SettingsScreen();
      default:
        return const JournalEntryScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
            AppTheme.primaryLight.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GradientHeader(
                icon: Icons.edit,
                title: 'New Journal Entry',
                description:
                    'Write your thoughts freely. Habits mentioned in your entries will be automatically created and scheduled.',
              ),
              const SizedBox(height: AppTheme.spacing60),
              Expanded(child: _buildEntryBox()),
            ],
          ),
        ),
      ),
    );

    if (!widget.showNavBar) {
      return body;
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildEntryBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: TextField(
        controller: _entryController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
          hintText:
              'Write your freeform journal entry here... Habits mentioned in your entries (e.g., \'I want to exercise every morning\' or \'wash hair every 4 days\') will be automatically created and scheduled.',
          hintStyle: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: AppTheme.fontSizeMedium,
            height: 1.5,
          ),
        ),
        style: AppTheme.body.copyWith(color: AppTheme.textPrimary, height: 1.5),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }
}
