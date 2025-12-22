import 'package:flutter/material.dart';
import 'package:project_micah/models/category_model.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/widgets/common/categories_card/categories_card.dart';

//TODO: change the name since this widget shares the same look with a motorcycle list
class CategoriesList extends StatefulWidget {
  final List<CategoryModel> categories;
  final EdgeInsetsGeometry padding;
  final Function(String categoryName)? onCategoryTap;
  final String? selectedCategory;

  const CategoriesList({
    super.key,
    required this.categories,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.onCategoryTap,
    this.selectedCategory,
  });

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollBy(double offset) async {
    // Ensure positions are available
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    final target = (current + offset).clamp(0.0, max);
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(builder: (context, constraints) {
        final totalWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final spacing = UIHelpers.spacing24;

        // Desktop: fixed visible count
        int visibleCount;
        double desiredItemWidth;
        double minItemWidth;
        double maxItemWidth;

        if (UIHelpers.isDesktop(context)) {
          visibleCount = 6;
          desiredItemWidth = 220.0;
          minItemWidth = 140.0;
          maxItemWidth = 340.0;
        } else {
          // Tablet/mobile: compute visibleCount based on desired width
          desiredItemWidth = UIHelpers.isTablet(context) ? 220.0 : 180.0;
          minItemWidth = desiredItemWidth * 0.75;
          maxItemWidth = desiredItemWidth * 1.25;

          // How many items of (desiredItemWidth + spacing) fit into totalWidth?
          visibleCount =
              ((totalWidth + spacing) / (desiredItemWidth + spacing)).floor();
          if (visibleCount < 1) visibleCount = 1;
        }

        // Compute final item width so `visibleCount` items exactly fill the row
        final totalSpacing = spacing * (visibleCount - 1);
        double itemWidth = (totalWidth - totalSpacing) / visibleCount;
        itemWidth = itemWidth.clamp(minItemWidth, maxItemWidth);

        final scrollChild = SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in widget.categories) ...[
                SizedBox(
                  width: itemWidth,
                  child: CategoriesCard(
                    title: category.name,
                    imagePath: category.imageUrl,
                    categoryName: category.name,
                    isSelected: widget.selectedCategory == category.name,
                    onTap: widget.onCategoryTap != null
                        ? () => widget.onCategoryTap!(category.name)
                        : null,
                  ),
                ),
                SizedBox(width: UIHelpers.spacing24),
              ]
            ],
          ),
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            scrollChild,
            Positioned(
              left: 4,
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _scrollBy(-(itemWidth + spacing)),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _scrollBy(itemWidth + spacing),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
