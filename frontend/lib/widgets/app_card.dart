import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable card widget with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  /// When null, uses [AppTheme.cardShadow]. Pass an empty list for no shadow.
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.constraints,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: boxShadow ?? AppTheme.cardShadow,
      ),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing20),
      constraints: constraints,
      child: child,
    );
  }
}

