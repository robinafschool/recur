import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable list item with consistent styling and bottom border
class ListItem extends StatelessWidget {
  final Widget child;
  final bool showBottomBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const ListItem({
    super.key,
    required this.child,
    this.showBottomBorder = true,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppTheme.spacing15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: showBottomBorder ? AppTheme.dividerColor : Colors.transparent,
            width: AppTheme.borderWidthThin,
          ),
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// List item with label and trailing widget
class LabeledListItem extends StatelessWidget {
  final String label;
  final Widget trailing;
  final bool showBottomBorder;
  final VoidCallback? onTap;

  const LabeledListItem({
    super.key,
    required this.label,
    required this.trailing,
    this.showBottomBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      showBottomBorder: showBottomBorder,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body),
          trailing,
        ],
      ),
    );
  }
}

