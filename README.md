# Project Micah

A Flutter application built with Stacked MVVM architecture featuring responsive layouts for mobile, tablet, and desktop.

## Features

- 🏗️ **Stacked Architecture**: Clean MVVM pattern with dependency injection
- 📱 **Responsive Design**: Separate views for mobile, tablet, and desktop using `ScreenTypeLayout.builder()`
- 🎨 **Multiple Flavors**: Development, Staging, and Production environments
- 🚀 **Code Generation**: Automated routing and dependency injection setup
- ✨ **Modern UI**: Smooth animations and transitions

## Project Structure

```
lib/
├── app/                          # Generated app files
│   ├── app.dart                  # Stacked app configuration
│   ├── app.router.dart          # Generated routes
│   ├── app.locator.dart         # Generated DI setup
│   ├── app.dialogs.dart         # Generated dialogs
│   └── app.bottomsheets.dart    # Generated bottom sheets
├── ui/
│   ├── views/                   # Feature views
│   │   ├── startup/            # Startup view with responsive layouts
│   │   │   ├── startup_view.dart
│   │   │   ├── startup_view.mobile.dart
│   │   │   ├── startup_view.tablet.dart
│   │   │   ├── startup_view.desktop.dart
│   │   │   └── startup_viewmodel.dart
│   │   ├── home/               # Home view with responsive layouts
│   │   │   ├── home_view.dart
│   │   │   ├── home_view.mobile.dart
│   │   │   ├── home_view.tablet.dart
│   │   │   ├── home_view.desktop.dart
│   │   │   └── home_viewmodel.dart
│   │   └── example/            # Example view template
│   ├── dialogs/                # Custom dialogs
│   ├── bottom_sheets/          # Custom bottom sheets
│   └── utils/                  # UI utilities
│       ├── constants/          # App constants
│       ├── theme/              # Theme configuration
│       └── device/             # Device utilities
├── main.dart                   # Production entry point
├── main_dev.dart              # Development entry point
├── main_stg.dart              # Staging entry point
└── bootstrap.dart             # App initialization logic
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (included with Flutter)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd project_micah
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Running the App

Run with different flavors:

**Production:**
```bash
flutter run -t lib/main.dart
```

**Development:**
```bash
flutter run -t lib/main_dev.dart
```

**Staging:**
```bash
flutter run -t lib/main_stg.dart
```

## Creating New Views

To create a new responsive view following the project pattern:

1. Create a new folder in `lib/ui/views/<view_name>/`

2. Create the following files:

**Main View (`<view_name>_view.dart`):**
```dart
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import '<view_name>_view.desktop.dart';
import '<view_name>_view.mobile.dart';
import '<view_name>_view.tablet.dart';
import '<view_name>_viewmodel.dart';

class YourView extends StackedView<YourViewModel> {
  const YourView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    YourViewModel viewModel,
    Widget? child,
  ) {
    return ScreenTypeLayout.builder(
      mobile: (_) => const YourViewMobile(),
      tablet: (_) => const YourViewTablet(),
      desktop: (_) => const YourViewDesktop(),
    );
  }

  @override
  YourViewModel viewModelBuilder(BuildContext context) => YourViewModel();
}
```

**ViewModel (`<view_name>_viewmodel.dart`):**
```dart
import 'package:stacked/stacked.dart';

class YourViewModel extends BaseViewModel {
  // Add your business logic here
}
```

**Mobile View (`<view_name>_view.mobile.dart`):**
```dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '<view_name>_viewmodel.dart';

class YourViewMobile extends ViewModelWidget<YourViewModel> {
  const YourViewMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, YourViewModel viewModel) {
    return Scaffold(
      // Mobile-specific UI
    );
  }
}
```

**Tablet View (`<view_name>_view.tablet.dart`):**
```dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '<view_name>_viewmodel.dart';

class YourViewTablet extends ViewModelWidget<YourViewModel> {
  const YourViewTablet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, YourViewModel viewModel) {
    return Scaffold(
      // Tablet-specific UI
    );
  }
}
```

**Desktop View (`<view_name>_view.desktop.dart`):**
```dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '<view_name>_viewmodel.dart';

class YourViewDesktop extends ViewModelWidget<YourViewModel> {
  const YourViewDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, YourViewModel viewModel) {
    return Scaffold(
      // Desktop-specific UI
    );
  }
}
```

3. Register the view in `lib/app/app.dart`:
```dart
@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: YourView), // Add your new view
    // ...
  ],
  // ...
)
```

4. Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Key Dependencies

- **stacked**: MVVM architecture framework
- **stacked_services**: Navigation, dialogs, and bottom sheets
- **stacked_generator**: Code generation for routing and DI
- **responsive_builder**: Responsive layout utilities
- **flutter_animate**: Animation library
- **url_strategy**: Web URL handling

## Architecture

This project follows the **Stacked MVVM** architecture:

- **Views**: UI layer, separate files for each screen size
- **ViewModels**: Business logic and state management
- **Services**: Reusable business logic (registered in `app.dart`)
- **Models**: Data structures
- **Repositories**: Data access layer

## Code Generation

The project uses code generation for:
- **Routing**: Automatic route generation from `app.dart`
- **Dependency Injection**: Service locator setup
- **Dialogs & Bottom Sheets**: UI component registration

Run generation after changes to `app.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

