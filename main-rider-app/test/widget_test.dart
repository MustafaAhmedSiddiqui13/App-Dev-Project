// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/Authentication/forgot_password.dart';
import 'package:rider_app/Authentication/login_screen.dart';
import 'package:rider_app/Authentication/register_screen.dart';
import 'package:rider_app/Startup%20Screens/dashboard.dart';
import 'package:rider_app/bloc/auth_bloc.dart';
import 'package:mockito/mockito.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  testWidgets('Dashboard should display the correct text',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: Dashboard()));

    // Find the text widget
    final textFinder = find.text('Dashboard');

    // Verify that the text widget is displayed
    expect(textFinder, findsOneWidget);
  });

  testWidgets('Dashboard should display the correct number of items',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: Dashboard()));

    // Find the list view widget
    final listViewFinder = find.byType(SingleChildScrollView);

    // Verify that the list view widget is displayed
    expect(listViewFinder, findsOneWidget);

    // Find the list view items
    final listItemsFinder = find.byType(Expanded);

    // Verify that the correct number of list view items are displayed
    expect(listItemsFinder, findsNWidgets(4));
  });

  testWidgets(
      'Dashboard should navigate to the correct screen when an item is tapped',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: Dashboard()));

    // Find the first list view item
    final listItemFinder = find.byType(Expanded).first;

    // Tap the first list view item
    await tester.tap(listItemFinder);

    // Rebuild the widget after the tap
    await tester.pumpAndSettle();

    // Verify that the correct screen is displayed
    expect(find.text('All Orders'), findsOneWidget);
  });

  group('LoginScreenContent Widget Tests', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets('Widget initializes with proper UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: LoginScreenContent(),
          ),
        ),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Login to your account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text("Don't have an account ? Sign Up"), findsOneWidget);
    });

    testWidgets('Tapping login button triggers LoginEvent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: LoginScreenContent(),
          ),
        ),
      );

      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration(seconds: 1));

      // Simulate a successful login event
      authBloc.add(AuthSuccess() as AuthEvent);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(LoginScreenContent), findsNothing);
      // You can add more assertions to check if the navigation is correctly performed.
    });

    testWidgets(
        'Tapping "Forgot Password?" navigates to Forgot Password screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: LoginScreenContent(),
          ),
        ),
      );

      final forgotPasswordButton = find.text('Forgot Password?');
      expect(forgotPasswordButton, findsOneWidget);

      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      // You can add more assertions to check if the navigation is correctly performed.
    });

    testWidgets(
        'Tapping "Don\'t have an account ? Sign Up" navigates to Register screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: LoginScreenContent(),
          ),
        ),
      );

      final signUpButton = find.text('Don\'t have an account ? Sign Up');
      expect(signUpButton, findsOneWidget);

      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(find.byType(RegistrationScreen), findsOneWidget);
      // You can add more assertions to check if the navigation is correctly performed.
    });
  });
}
