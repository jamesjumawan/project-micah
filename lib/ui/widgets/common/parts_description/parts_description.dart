import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/text_strings.dart';

class PartsDescription extends StatelessWidget {
  final String imageUrl;
  final String partsName;
  final String sku;
  final String category;
  final String description;
  final String partNo;
  final int quantity;
  final String groupNo;
  final String label;

  const PartsDescription({
    super.key,
    required this.imageUrl,
    required this.partsName,
    required this.sku,
    required this.category,
    required this.description,
    required this.partNo,
    required this.quantity,
    required this.groupNo,
    this.label = TTexts.clutchLabel,
  });

  Widget _metaRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = UIHelpers.isDesktop(context);

    return Padding(
      padding: UIHelpers.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top label (like "CLUTCH")
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
          ),
          UIHelpers.verticalSpace24,
          Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: image area
              Flexible(
                flex: isDesktop ? 5 : 0,
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(24),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    height: isDesktop ? 400 : 280,
                    width: double.infinity,
                    errorBuilder: (c, e, st) => const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),

              SizedBox(
                  width: isDesktop ? UIHelpers.spacing48 : 0,
                  height: isDesktop ? 0 : UIHelpers.spacing24),

              // Right: metadata section
              Flexible(
                flex: isDesktop ? 5 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parts name as title
                    Text(
                      partsName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                    ),
                    UIHelpers.verticalSpace16,
                    // Category as clickable link
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    UIHelpers.verticalSpace24,
                    // Metadata rows
                    _metaRow(TTexts.skuLabel, sku),
                    _metaRow(TTexts.categoryLabel, category),
                    _metaRow(TTexts.groupNoLabel, groupNo),
                    _metaRow(TTexts.partNoLabel, partNo),
                    _metaRow(TTexts.quantityLabel, quantity.toString()),
                    UIHelpers.verticalSpace24,
                    Text(
                      TTexts.descriptionLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    UIHelpers.verticalSpace12,
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
