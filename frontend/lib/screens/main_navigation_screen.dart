import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/route_generator.dart';
import 'analytics_screen.dart';
import 'journal_list_screen.dart';
import 'journal_entry_screen.dart';
import 'ai_schedule_screen.dart';
import 'settings_screen.dart';

/// Main navigation screen that keeps the bottom nav bar persistent
/// Uses AnimatedSwitcher with custom transitions for smooth page changes
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 1,
  });

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

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const AnalyticsScreen(showNavBar: false);
      case 1:
        return const JournalListScreen(showNavBar: false);
      case 2:
        return const JournalEntryScreen(showNavBar: false);
      case 3:
        return const AiScheduleScreen(showNavBar: false);
      case 4:
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
          // Determine slide direction based on navigation
          final direction = getSlideDirection(_previousIndex, _currentIndex);
          
          // For incoming page (animation goes 0 -> 1)
          Offset incomingBegin;
          // For outgoing page (animation goes 0 -> 1, but we reverse it)
          Offset outgoingEnd;
          
          switch (direction) {
            case SlideDirection.left:
              // Moving left: new page comes from right, old page exits to left
              incomingBegin = const Offset(1.0, 0.0);
              outgoingEnd = const Offset(-1.0, 0.0);
              break;
            case SlideDirection.right:
              // Moving right: new page comes from left, old page exits to right
              incomingBegin = const Offset(-1.0, 0.0);
              outgoingEnd = const Offset(1.0, 0.0);
              break;
            case SlideDirection.center:
              // Shouldn't happen, but fallback to fade
              incomingBegin = Offset.zero;
              outgoingEnd = Offset.zero;
              break;
          }

          // Check if this is the incoming or outgoing child
          final isIncoming = child.key == ValueKey<int>(_currentIndex);

          if (isIncoming) {
            // Incoming page: animation goes 0→1, slide in from begin to center
            return SlideTransition(
              position: Tween<Offset>(
                begin: incomingBegin,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          } else {
            // Outgoing page: AnimatedSwitcher reverses animation (1→0)
            // So we need to SWAP begin/end: it starts at "end" and moves to "begin"
            // We want it to start at center and move to outgoingEnd
            // So: begin = outgoingEnd, end = Offset.zero
            return SlideTransition(
              position: Tween<Offset>(
                begin: outgoingEnd,  // Swapped! Starts here when animation=1
                end: Offset.zero,    // Swapped! Ends here when animation=0
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          }
        },
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          // Stack the pages so they slide over each other
          return Stack(
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _getCurrentPage(),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

