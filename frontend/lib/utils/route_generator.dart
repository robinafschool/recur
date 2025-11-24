import 'package:flutter/material.dart';

/// Custom route generator with slide transitions based on navigation direction
/// Only animates the body content, keeping bottomNavigationBar persistent
class SlideRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;

  SlideRoute({
    required this.page,
    this.direction = SlideDirection.left,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Extract bottomNavigationBar if child is a Scaffold
            Widget? bottomNavBar;
            Widget bodyWidget = child;
            
            if (child is Scaffold) {
              bottomNavBar = child.bottomNavigationBar;
              // Recreate Scaffold with all properties except bottomNavigationBar
              bodyWidget = Scaffold(
                body: child.body,
                backgroundColor: child.backgroundColor,
                resizeToAvoidBottomInset: child.resizeToAvoidBottomInset,
                appBar: child.appBar,
                floatingActionButton: child.floatingActionButton,
                drawer: child.drawer,
                endDrawer: child.endDrawer,
                bottomSheet: child.bottomSheet,
              );
            }

            Offset begin;
            Offset end = Offset.zero;

            switch (direction) {
              case SlideDirection.left:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.center:
                begin = const Offset(0.0, 1.0);
                break;
            }

            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            // Use Column to separate animated body from fixed nav bar
            return Column(
              children: [
                // Animated body content - takes all available space above nav bar
                Expanded(
                  child: ClipRect(
                    child: SlideTransition(
                      position: animation.drive(tween),
                      child: bodyWidget,
                    ),
                  ),
                ),
                // Fixed bottom navigation bar - completely outside animation
                if (bottomNavBar != null)
                  IgnorePointer(
                    ignoring: animation.value < 1.0,
                    child: bottomNavBar,
                  ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

enum SlideDirection {
  left,
  right,
  center,
}

/// Helper function to get slide direction based on current and target index
SlideDirection getSlideDirection(int currentIndex, int targetIndex) {
  if (targetIndex < currentIndex) {
    return SlideDirection.right;
  } else if (targetIndex > currentIndex) {
    return SlideDirection.left;
  } else {
    return SlideDirection.center;
  }
}

