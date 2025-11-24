import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../utils/route_generator.dart';
import '../navigation/navigation.dart';
import 'analytics_screen.dart';
import 'journal_list_screen.dart';
import 'journal_entry_screen.dart';
import 'ai_schedule_screen.dart';
import 'settings_screen.dart';

/// Main navigation screen that keeps the bottom nav bar persistent
/// Uses AnimatedSwitcher with custom transitions for smooth page changes
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 1});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  int _previousIndex = 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _previousIndex = _currentIndex;
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _previousIndex = _currentIndex;
        _currentIndex = index;
      });
    }
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case NavIndex.analytics:
        return const AnalyticsScreen(showNavBar: false);
      case NavIndex.journalList:
        return const JournalListScreen(showNavBar: false);
      case NavIndex.journalEntry:
        return const JournalEntryScreen(showNavBar: false);
      case NavIndex.aiSchedule:
        return const AiScheduleScreen(showNavBar: false);
      case NavIndex.settings:
        return const SettingsScreen(showNavBar: false);
      default:
        return const JournalListScreen(showNavBar: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isNavigatingToJournalEntry = _currentIndex == NavIndex.journalEntry;

          Offset incomingBegin;
          Offset outgoingEnd;

          if (isNavigatingToJournalEntry) {
            incomingBegin = const Offset(0.0, 1.0);
            outgoingEnd = const Offset(0.0, -1.0);
          } else {
            final direction = getSlideDirection(_previousIndex, _currentIndex);

            switch (direction) {
              case SlideDirection.left:
                incomingBegin = const Offset(1.0, 0.0);
                outgoingEnd = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.right:
                incomingBegin = const Offset(-1.0, 0.0);
                outgoingEnd = const Offset(1.0, 0.0);
                break;
              case SlideDirection.center:
                incomingBegin = Offset.zero;
                outgoingEnd = Offset.zero;
                break;
            }
          }

          final isIncoming = child.key == ValueKey<int>(_currentIndex);

          if (isIncoming) {
            return SlideTransition(
              position: Tween<Offset>(begin: incomingBegin, end: Offset.zero)
                  .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );
          } else {
            return SlideTransition(
              position: Tween<Offset>(
                begin: outgoingEnd,
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );
          }
        },
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _getScreenForIndex(_currentIndex),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
