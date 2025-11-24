# UI Utils Documentation

This directory contains all utility classes, constants, extensions, and helpers for the UI layer.

## Structure

```
lib/ui/utils/
├── constants/
│   ├── app_colors.dart       # All color definitions
│   ├── app_constants.dart    # App-wide constants
│   ├── app_images.dart       # Image asset paths
│   ├── text_strings.dart     # Static text strings
│   └── ui_helpers.dart       # Spacing, sizing, responsive helpers
├── device/
│   └── web_material_scroll.dart  # Custom scroll behavior
├── extensions/
│   ├── context_extensions.dart   # BuildContext extensions
│   ├── datetime_extensions.dart  # DateTime extensions
│   ├── number_extensions.dart    # Int/Double extensions
│   └── string_extensions.dart    # String extensions
├── theme/
│   └── theme.dart            # App theme configuration
└── validators/
    └── validators.dart       # Form validation helpers
```

## Usage Guide

### Colors
Always use `AppColors` for all color values:
```dart
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textWhite),
  ),
)
```

### Spacing
Use `UIHelpers` for consistent spacing:
```dart
Column(
  children: [
    Text('Title'),
    UIHelpers.verticalSpace16,
    Text('Content'),
  ],
)
```

### Theme
Theme is configured in `theme.dart` with:
- **Primary Color**: #399ADE (Blue)
- **Secondary Color**: #F6C614 (Yellow)
- **Font**: Archivo (via Google Fonts)

### Extensions

**Context Extensions:**
```dart
context.screenWidth
context.isMobile
context.showSuccessSnackBar('Success!')
```

**String Extensions:**
```dart
email.isValidEmail
'hello world'.capitalize  // 'Hello world'
'hello world'.capitalizeWords  // 'Hello World'
```

**DateTime Extensions:**
```dart
DateTime.now().toFormattedDate()  // 'Nov 24, 2025'
DateTime.now().toRelativeTime()   // '5m ago'
```

**Number Extensions:**
```dart
1250.toCurrency()  // '$1250.00'
1500000.toAbbreviated()  // '1.5M'
```

### Validators
Use `Validators` for form validation:
```dart
TextFormField(
  validator: Validators.validateEmail,
)
```

## Design System

### Color Palette
- **Primary**: #399ADE (Main brand color)
- **Secondary**: #F6C614 (Accent/highlight)
- **Success**: #4CAF50
- **Error**: #F44336
- **Warning**: #FF9800
- **Info**: #2196F3

### Spacing Scale
- 4, 8, 12, 16, 20, 24, 32, 40, 48, 64

### Border Radius
- Small: 4px
- Medium: 8px
- Large: 12px
- XLarge: 16px

### Breakpoints
- Mobile: < 600px
- Tablet: 600px - 1200px
- Desktop: > 1200px

## Best Practices

1. **Never hardcode colors** - Always use `AppColors`
2. **Never hardcode spacing** - Use `UIHelpers` constants
3. **Never hardcode text** - Use `TTexts` constants
4. **Use extensions** - Leverage context, string, and datetime extensions
5. **Validate forms** - Use `Validators` for consistent validation
6. **Follow theme** - All styles should come from `theme.dart`
