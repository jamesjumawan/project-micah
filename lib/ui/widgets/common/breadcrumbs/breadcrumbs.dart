import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart' as fb;

/// Breadcrumbs wrapper using `flutter_breadcrumb` package.
///
/// Example:
/// Breadcrumbs(items: ['Home', 'Categories'])
class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<String> items;
  final void Function(int index, String label)? onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return fb.BreadCrumb(
      items: items
          .asMap()
          .entries
          .map((e) => fb.BreadCrumbItem(
                content: Text(
                  e.value,
                  style: e.key == items.length - 1
                      ? textStyle?.copyWith(fontWeight: FontWeight.w600)
                      : textStyle,
                ),
                onTap: e.key == items.length - 1
                    ? null
                    : () => onTap?.call(e.key, e.value),
              ))
          .toList(),
      divider: const Icon(Icons.chevron_right, size: 16),
    );
  }
}
