# Project Micah

A Flutter application built with Stacked MVVM architecture featuring responsive layouts for mobile, tablet, and desktop.



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
