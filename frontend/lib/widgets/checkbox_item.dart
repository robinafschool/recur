import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable checkbox item widget
class CheckboxItem extends StatelessWidget {
  final bool isChecked;
  final String label;
  final ValueChanged<bool>? onChanged;

  const CheckboxItem({
    super.key,
    required this.isChecked,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor,
            width: AppTheme.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onChanged != null ? () => onChanged!(!isChecked) : null,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isChecked ? AppTheme.primaryColor : AppTheme.backgroundColor,
                border: Border.all(
                  color: isChecked ? AppTheme.primaryColor : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppTheme.spacing15),
          Expanded(
            child: Text(
              label,
              style: AppTheme.body,
            ),
          ),
        ],
      ),
    );
  }
}

