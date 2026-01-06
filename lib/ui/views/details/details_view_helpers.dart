import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class ToggleButton extends StatefulWidget {
  final bool isAssembleMode;
  final bool isEnabled;
  final VoidCallback onToggle;

  const ToggleButton({
    super.key,
    required this.isAssembleMode,
    this.isEnabled = true,
    required this.onToggle,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isEnabled ? 1.0 : 0.5,
      child: MouseRegion(
        cursor: widget.isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _isHovered = widget.isEnabled),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.isEnabled ? widget.onToggle : null,
          borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: UIHelpers.spacing12,
              vertical: UIHelpers.spacing8,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
              border: Border.all(
                color: _isHovered ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isAssembleMode
                      ? Icons.construction
                      : Icons.auto_fix_high,
                  size: UIHelpers.iconMedium,
                  color: widget.isAssembleMode
                      ? AppColors.success
                      : AppColors.warning,
                ),
                UIHelpers.horizontalSpace8,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAssembleMode ? 'ASSEMBLE' : 'DISASSEMBLE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      widget.isAssembleMode ? 'Full View' : 'Parts View',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                UIHelpers.horizontalSpace8,
                Icon(
                  Icons.swap_horiz,
                  size: UIHelpers.iconSmall,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ControlItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String action;

  const ControlItem({
    super.key,
    required this.icon,
    required this.label,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        UIHelpers.horizontalSpace4,
        Text(
          '$label: $action',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
