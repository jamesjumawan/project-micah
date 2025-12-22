import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';

class AccordionCard extends StatefulWidget {
  final Widget title;
  final Widget body;
  final bool isOpen;

  const AccordionCard({
    super.key,
    required this.title,
    required this.body,
    this.isOpen = true,
  });

  @override
  State<AccordionCard> createState() => _AccordionCardState();
}

class _AccordionCardState extends State<AccordionCard> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.isOpen;
  }

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.divider,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIHelpers.spacing16,
                vertical: UIHelpers.spacing12,
              ),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: AppColors.primaryDark,
                      size: UIHelpers.iconMedium,
                    ),
                  ),
                  Expanded(child: widget.title),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _open
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIHelpers.spacing16,
                        vertical: UIHelpers.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardLight,
                        border:
                            Border(top: BorderSide(color: AppColors.surface)),
                      ),
                      child: widget.body,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
