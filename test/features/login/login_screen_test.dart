import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';
import 'package:flutter_dvmatyun/features/login/domain/auth_exception.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_controller.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

class _ReplaceCounter extends NavigatorObserver {
  int count = 0;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      count++;
}

void main() {
  late FakeUserService service;
  late UserController controller;
  late _ReplaceCounter replaces;

  setUp(() {
    service = FakeUserService();
    controller = UserController(userService: service);
    replaces = _ReplaceCounter();
  });

  tearDown(() => controller.dispose());

  Future<void> pumpLoginScreen(WidgetTester tester) => tester.pumpWidget(
    AppScope(
      data: AppScopeData(userService: service, userController: controller),
      child: MaterialApp(
        home: const LoginScreen(),
        navigatorObservers: [replaces],
        routes: {AppRoutes.home: (_) => const Text('Home screen')},
      ),
    ),
  );

  Future<void> logIn(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).first, 'john');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('empty fields are validated in the form', (tester) async {
    await pumpLoginScreen(tester);
    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(find.text('Enter your login'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(service.loginCalls, 0);
  });

  testWidgets('successful login navigates to home once', (tester) async {
    await pumpLoginScreen(tester);
    await logIn(tester);
    expect(find.text('Home screen'), findsOneWidget);
    expect(replaces.count, 1);
  });

  testWidgets('failed login shows a single error dialog', (tester) async {
    service.error = const AuthException('Invalid login or password.');
    await pumpLoginScreen(tester);
    await logIn(tester);
    expect(find.text('Login failed'), findsOneWidget);
    expect(find.text('Invalid login or password.'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Login failed'), findsNothing);
    expect(replaces.count, 0);
  });

  testWidgets('password visibility is toggled locally', (tester) async {
    await pumpLoginScreen(tester);
    EditableText password() =>
        tester.widget<EditableText>(find.byType(EditableText).last);
    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(password().obscureText, isFalse);
    expect(controller.state.isLoading, isFalse);
  });
}
