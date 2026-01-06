import 'package:flutter_test/flutter_test.dart';
import 'package:project_micah/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('MotorcycleShowcaseModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
