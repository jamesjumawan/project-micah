import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/text_strings.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';

/// Sidebar panel shown when a sub-assembly (SA-xxxx) is clicked.
/// Lists the child parts of that sub-assembly, or shows "Coming Soon"
/// if none are available yet. Back button returns to the full view.
class SubAssemblySidebar extends StatelessWidget {
  /// e.g. 'SA-F05-01'
  final String saCode;

  /// Parts belonging to this sub-assembly.
  /// Each map has keys: displayName, item_code, obj, mtl, sub_assembly.
  final List<Map<String, String>> parts;

  /// Called when a child part is tapped.
  final void Function(String itemCode, String displayName)? onPartTap;

  /// Called when the back button is tapped.
  final VoidCallback onBack;

  const SubAssemblySidebar({
    super.key,
    required this.saCode,
    required this.parts,
    required this.onBack,
    this.onPartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIHelpers.spacing16,
            vertical: UIHelpers.spacing12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        TTexts.back,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              UIHelpers.horizontalSpace12,
              Expanded(
                child: Text(
                  saCode,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // ── Sub-assembly label ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UIHelpers.spacing16,
            UIHelpers.spacing16,
            UIHelpers.spacing16,
            UIHelpers.spacing8,
          ),
          child: Text(
            TTexts.subAssemblyDetails,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
          ),
        ),

        // ── Parts list ─────────────────────────────────────────────────────────────────
        Expanded(
          child: parts.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  padding: const EdgeInsets.all(UIHelpers.spacing12),
                  itemCount: parts.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: AppColors.border, height: 1),
                  itemBuilder: (context, index) {
                    final part = parts[index];
                    final code = part['item_code'] ?? '';
                    final name = part['displayName'] ?? code;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: UIHelpers.spacing8,
                        vertical: 2,
                      ),
                      title: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      subtitle: code.isNotEmpty
                          ? Text(
                              code,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                            )
                          : null,
                      trailing: const Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textHint),
                      onTap: onPartTap != null && code.isNotEmpty
                          ? () => onPartTap!(code, name)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
