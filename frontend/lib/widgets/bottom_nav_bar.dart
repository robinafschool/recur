import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Animated nav item that shows a tap feedback animation
class _AnimatedNavItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final bool isActive;
  final bool isJournalEntry;
  final Function(int) onTap;

  const _AnimatedNavItem({
    required this.index,
    required this.icon,
    required this.isActive,
    required this.isJournalEntry,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    // Animate IN on press
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    // Animate OUT on release and trigger navigation
    _controller.reverse();
    widget.onTap(widget.index);
  }

  void _handleTapCancel() {
    // Animate OUT if tap is cancelled (e.g., finger dragged away)
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Journal Entry button - no animation, just tap
    if (widget.isJournalEntry) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTap(widget.index),
        child: Container(
          width: 75,
          height: 75,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: AppTheme.buttonShadow,
            ),
            child: Center(
              child: Icon(widget.icon, color: Colors.white, size: 30),
            ),
          ),
        ),
      );
    }

    // Other buttons - with press/release animation
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          final hitboxColor = widget.isActive
              ? AppTheme.primaryColor
              : AppTheme.textSecondary;

          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: hitboxColor.withOpacity(_opacityAnimation.value),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(AppTheme.spacing8),
              child: Icon(
                widget.icon,
                color: widget.isActive
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary.withOpacity(0.6),
                size: 26,
              ),
            ),
          );
        },
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing10,
        horizontal: AppTheme.spacing10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AnimatedNavItem(
            index: 0,
            icon: Icons.insights,
            isActive: currentIndex == 0,
            isJournalEntry: false,
            onTap: onTap,
          ),
          _AnimatedNavItem(
            index: 1,
            icon: Icons.book_outlined,
            isActive: currentIndex == 1,
            isJournalEntry: false,
            onTap: onTap,
          ),
          _AnimatedNavItem(
            index: 2,
            icon: Icons.edit,
            isActive: currentIndex == 2,
            isJournalEntry: true,
            onTap: onTap,
          ),
          _AnimatedNavItem(
            index: 3,
            icon: Icons.schedule,
            isActive: currentIndex == 3,
            isJournalEntry: false,
            onTap: onTap,
          ),
          _AnimatedNavItem(
            index: 4,
            icon: Icons.settings_outlined,
            isActive: currentIndex == 4,
            isJournalEntry: false,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
