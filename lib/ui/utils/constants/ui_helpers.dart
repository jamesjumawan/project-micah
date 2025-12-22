import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class UIHelpers {
  UIHelpers._();

  // Spacing Constants
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 100.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Vertical Spacing Widgets
  static const Widget verticalSpace4 = SizedBox(height: spacing4);
  static const Widget verticalSpace8 = SizedBox(height: spacing8);
  static const Widget verticalSpace12 = SizedBox(height: spacing12);
  static const Widget verticalSpace16 = SizedBox(height: spacing16);
  static const Widget verticalSpace20 = SizedBox(height: spacing20);
  static const Widget verticalSpace24 = SizedBox(height: spacing24);
  static const Widget verticalSpace32 = SizedBox(height: spacing32);
  static const Widget verticalSpace40 = SizedBox(height: spacing40);
  static const Widget verticalSpace48 = SizedBox(height: spacing48);
  static const Widget verticalSpace64 = SizedBox(height: spacing64);

  // Horizontal Spacing Widgets
  static const Widget horizontalSpace4 = SizedBox(width: spacing4);
  static const Widget horizontalSpace8 = SizedBox(width: spacing8);
  static const Widget horizontalSpace12 = SizedBox(width: spacing12);
  static const Widget horizontalSpace16 = SizedBox(width: spacing16);
  static const Widget horizontalSpace20 = SizedBox(width: spacing20);
  static const Widget horizontalSpace24 = SizedBox(width: spacing24);
  static const Widget horizontalSpace32 = SizedBox(width: spacing32);
  static const Widget horizontalSpace40 = SizedBox(width: spacing40);
  static const Widget horizontalSpace48 = SizedBox(width: spacing48);
  static const Widget horizontalSpace64 = SizedBox(width: spacing64);

  // Helper Methods
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < mobileBreakpoint;
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= mobileBreakpoint &&
      screenWidth(context) < desktopBreakpoint;
  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= desktopBreakpoint;

  static EdgeInsets pagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(spacing16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(spacing24);
    } else {
      return const EdgeInsets.all(spacing32);
    }
  }

  static double contentWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isDesktop(context)) {
      return width * 0.8 > 1200 ? 1200 : width * 0.8;
    }
    return width;
  }

  /// Apply text style deltas to a base [TextStyle]. This centralizes the
  /// logic so callers don't have to use `copyWith` across the codebase.
  static TextStyle? applyTextStyle(
    TextStyle? base, {
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    final delta = TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );

    if (base == null) return delta;
    return base.merge(delta);
  }
}

// TextStyle helper utilities to avoid repeated use of copyWith throughout the
// codebase. Use these helpers from extensions below.
// Public extension for convenient TextStyle transformations. This mirrors the
// getters you requested but delegates the actual style creation to the
// UIHelpers internals so we avoid sprinkling copyWith across the codebase.
extension TextStylesExtension on TextStyle? {
  TextStyle? get fontSize12 => UIHelpers.applyTextStyle(this, fontSize: 12);
  TextStyle? get fontSize14 => UIHelpers.applyTextStyle(this, fontSize: 14);
  TextStyle? get fontSize16 => UIHelpers.applyTextStyle(this, fontSize: 16);
  TextStyle? get fontSize18 => UIHelpers.applyTextStyle(this, fontSize: 18);
  TextStyle? get fontSize20 => UIHelpers.applyTextStyle(this, fontSize: 20);
  TextStyle? get fontSize24 => UIHelpers.applyTextStyle(this, fontSize: 24);

  TextStyle? get primary =>
      UIHelpers.applyTextStyle(this, color: AppColors.primary);
  TextStyle? get secondary =>
      UIHelpers.applyTextStyle(this, color: AppColors.secondary);
  TextStyle? get accentRed =>
      UIHelpers.applyTextStyle(this, color: AppColors.error);
  TextStyle? get white =>
      UIHelpers.applyTextStyle(this, color: AppColors.textWhite);
  TextStyle? get black => UIHelpers.applyTextStyle(this, color: Colors.black);

  TextStyle? get bold =>
      UIHelpers.applyTextStyle(this, fontWeight: FontWeight.bold);
  TextStyle? get normal =>
      UIHelpers.applyTextStyle(this, fontWeight: FontWeight.normal);
  TextStyle? get italic =>
      UIHelpers.applyTextStyle(this, fontStyle: FontStyle.italic);
  TextStyle? get underline =>
      UIHelpers.applyTextStyle(this, decoration: TextDecoration.underline);
}
