import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recur/config/app_theme.dart';
import 'package:recur/navigation/navigation.dart';
import 'package:recur/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('renders Sign In button and Recur title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.theme,
            routes: {
              AppRoutes.login: (context) => const LoginScreen(),
            },
            initialRoute: AppRoutes.login,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Recur'), findsOneWidget);
    }, skip: true); // Requires Supabase provider overrides or integration test
  });
}
