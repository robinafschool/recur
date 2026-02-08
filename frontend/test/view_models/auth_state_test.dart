import 'package:flutter_test/flutter_test.dart';
import 'package:recur/view_models/auth_view_model.dart';

void main() {
  group('AuthState', () {
    test('copyWith updates isLoading', () {
      const state = AuthState(isLoading: false);
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, true);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith clears errorMessage', () {
      const state = AuthState(errorMessage: 'Error');
      final updated = state.copyWith(errorMessage: null);
      expect(updated.errorMessage, isNull);
    });
  });
}
