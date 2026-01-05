import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable scaffold with gradient background used across multiple screens
/// The gradient always fills the entire screen, even when content is minimal
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final gradientContainer = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.7),
            AppTheme.primaryLight.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: child,
      ),
    );

    if (bottomNavigationBar == null) {
      return gradientContainer;
    }

    return Scaffold(
      body: gradientContainer,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

