import 'package:flutter/material.dart';

/// Model representing a settings item with label, trailing widget, and optional tap handler
class SettingItem {
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  SettingItem({required this.label, required this.trailing, this.onTap});
}

