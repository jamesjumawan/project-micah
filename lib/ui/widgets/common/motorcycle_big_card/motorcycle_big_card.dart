import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:stacked/stacked.dart';

import 'motorcycle_big_card_model.dart';

class MotorcycleBigCard extends StackedView<MotorcycleBigCardModel> {
  final String title;
  final String? imagePath;
  final VoidCallback? onTap;

  const MotorcycleBigCard({
    super.key,
    this.title = '',
    this.imagePath,
    this.onTap,
  });

  double _heightFor(BuildContext context) {
    if (UIHelpers.isDesktop(context)) return 360.0;
    if (UIHelpers.isTablet(context)) return 300.0;
    return 220.0;
  }

  @override
  Widget builder(
    BuildContext context,
    MotorcycleBigCardModel viewModel,
    Widget? child,
  ) {
    final height = _heightFor(context);

    // Wrap the visual card in a Material + InkWell so taps show a ripple and
    // can be handled by parent widgets. Use a transparent Material to avoid
    // changing the visual background.
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // background color
              Container(color: AppColors.surface),

              // overlay image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/overlay.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // title
                    Expanded(
                      flex: 4,
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                    ),

                    // image
                    Expanded(
                      flex: 6,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: imagePath != null
                            ? (imagePath!.startsWith('http')
                                ? Image.network(
                                    imagePath!,
                                    fit: BoxFit.contain,
                                    height: height * 0.9,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: height * 0.9,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox(
                                        height: height * 0.9,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: UIHelpers.iconXLarge,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    imagePath!,
                                    fit: BoxFit.contain,
                                    height: height * 0.9,
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox(
                                        height: height * 0.9,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: UIHelpers.iconXLarge,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                      );
                                    },
                                  ))
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  MotorcycleBigCardModel viewModelBuilder(
    BuildContext context,
  ) =>
      MotorcycleBigCardModel();
}
