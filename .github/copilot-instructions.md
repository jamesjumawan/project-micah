---
applyTo: '**'
---

# 📘 Project Development Guidelines

These guidelines ensure consistency, performance, and maintainability across the codebase. Follow them strictly when contributing.

---

## 🔑 General Principles
- Always **consider time complexity** when writing logic.
- Keep **logic and computations inside models**, not views.
- Follow [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices).
- Code should be **modular, reusable, and readable**.
- Prefer **functions or widgets** over inline or repetitive code.
- Strive to keep **each file minimal** in line count; extract reusable patterns.
- Minimize use of variables — compute directly where possible without harming readability.
- Make sure when you remove the theme files and colors, it can still run without errors.

---

## 🎨 UI Guidelines
- ❌ **Do not use themes inside views**.  
- ✅ Always configure styles in `theme.dart`.  
  - Example: If you see a **green button**, configure it in `theme.dart` instead of applying style inline.  
- Always use:
  - `app_colors.dart` → for all colors  
  - `text_strings.dart` → for static texts  
  - `ui_helpers.dart` → for spacing, dimensions, and other utilities  
- If these files don't exist, **create them** and maintain consistency.  
- Avoid **overusing `Padding`** in views — use spacing helpers instead.  
- Build **responsive UI** that adapts to all screen sizes.

---

## 🏗️ Architecture Guidelines
- Use **service classes** for API handling and business logic.  
- Keep **client classes** (Retrofit + Dio) lean and focused only on API contract definitions.  
- All error handling should:
  - **Log errors** properly  
  - **Show feedback to users** (snackbar, dialogs, etc.)  
  - **Throw meaningful exceptions**  

---

## 🔧 Example Service & Client Pattern

### `service.dart`
```dart
@LazySingleton()
class LiquidationService {
  LiquidationService({
    LiquidationClient? liquidationClient,
    CacheService? cacheService,
  })  : _cacheService = cacheService ?? locator<CacheService>(),
        _client = liquidationClient ?? locator<LiquidationClient>();

  final LiquidationClient _client;
  final CacheService _cacheService;

  Future<List<Liquidation>> getLiquidations() async {
    try {
      final userType = _cacheService.getUserType();
      String? liaisonUserId = 
          userType == UserType.liaison ? _cacheService.getUserId() : null;

      return await _client.getLiquidations(liaisonUserId: liaisonUserId);
    } on DioException catch (e) {
      log(e.toString());
      showErrorSnackbar('Failed to fetch liquidations');
      throw Exception('Failed to fetch liquidations');
    }
  }

  Future<LiquidationDetails?> getLiquidationDetails({
    required String cashAdvanceId,
    required String cashAdvanceDetailId,
  }) async {
    try {
      return await _client.getLiquidationDetails(
        cashAdvanceId: cashAdvanceId,
        cashAdvanceDetailId: cashAdvanceDetailId,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      log(e.toString());
      showErrorSnackbar('Failed to fetch liquidation details');
      throw Exception('Failed to fetch liquidation details');
    }
  }

  Future<void> createLiquidation(FormData formData) async {
    try {
      final resp = await _client.createLiquidation(formData);
      if (resp.isFailure || !resp.isSuccess) {
        final msg = resp.error?.message ?? 'Failed to create liquidation';
        showErrorSnackbar(msg);
        throw Exception(msg);
      }
    } on DioException catch (e) {
      log(e.toString());
      showErrorSnackbar('Failed to create liquidation');
      throw Exception('Failed to create liquidation');
    }
  }
}
```

### `client.dart`
```dart
@RestApi(baseUrl: 'https://your-api-base-url/api')
abstract class LiquidationClient {
  factory LiquidationClient(Dio dio, {String baseUrl}) = _LiquidationClient;

  @POST('/Liquidation')
  @MultiPart()
  Future<ApiResponse> createLiquidation(@Body() FormData body);

  @GET('/Liquidation')
  Future<List<Liquidation>> getLiquidations({
    @Query('liaisonUserId') String? liaisonUserId,
  });

  @GET('/Liquidation/details')
  Future<LiquidationDetails> getLiquidationDetails({
    @Query('cashAdvanceId') required String cashAdvanceId,
    @Query('cashAdvanceDetailId') required String cashAdvanceDetailId,
  });

  @POST('/Liquidation/complete')
  @MultiPart()
  Future<ApiResponse> completeLiquidation(@Body() FormData body);

  @POST('/Verification/{cashAdvanceId}/verify')
  Future<ApiResponse> verifyLiquidation(
    @Path('cashAdvanceId') String cashAdvanceId,
  );

  @PUT('/Verification/motorcycle/verify')
  Future<void> verifyMotorcycle(
    @Query('cashAdvanceId') String cashAdvanceId,
    @Query('cashAdvanceDetailId') String cashAdvanceDetailId,
    @Query('accountingUserId') String accountingUserId,
    @Query('remarks') String? remarks,
  );

  @PUT('/Liquidation/update/fees')
  Future<void> updateLiquidationAmount(
    @Query('cashAdvanceId') String cashAdvanceId,
    @Query('cashAdvanceDetailId') String cashAdvanceDetailId,
    @Query('actualProcessedAmount') double? actualProcessedAmount,
    @Query('surplusAmount') double? surplusAmount,
  );
}
```

---

## Flutter MVVM Project Setup - Project Micah

### Project Type
Flutter application using Stacked architecture with MVVM pattern

### Status: ✅ COMPLETED

### Features Implemented
- ✅ Stacked MVVM architecture with dependency injection
- ✅ Responsive layouts (mobile, tablet, desktop) using ScreenTypeLayout.builder()
- ✅ Multiple flavors (Dev, Staging, Production)
- ✅ Bootstrap pattern for app initialization
- ✅ Code generation for routing and dependency injection
- ✅ Example views demonstrating responsive pattern
- ✅ Theme and styling utilities
- ✅ Navigation service setup

### Project Structure
Each view follows this pattern:
- `view_name_view.dart` - Main view using ScreenTypeLayout.builder()
- `view_name_view.mobile.dart` - Mobile-specific UI
- `view_name_view.tablet.dart` - Tablet-specific UI  
- `view_name_view.desktop.dart` - Desktop-specific UI
- `view_name_viewmodel.dart` - Business logic

### Available Commands
```bash
# Run production
flutter run -t lib/main.dart

# Run development
flutter run -t lib/main_dev.dart

# Run staging
flutter run -t lib/main_stg.dart

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Watch for changes
dart run build_runner watch --delete-conflicting-outputs
```

### Next Steps
- Add more feature views following the established pattern
- Implement services in `lib/services/`
- Add models in `lib/models/`
- Configure CI/CD for different flavors
- Add tests for views and viewmodels

