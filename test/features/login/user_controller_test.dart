import 'package:flutter_dvmatyun/features/login/domain/auth_exception.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_controller.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeUserService service;
  late UserController controller;
  late List<LoginState> states;

  setUp(() {
    service = FakeUserService();
    controller = UserController(userService: service);
    states = [];
    controller.addListener(() => states.add(controller.state));
  });

  tearDown(() => controller.dispose());

  test('initialize restores the saved user', () async {
    service.savedUser = testUser;
    expect(await controller.initialize(), testUser);
    expect(controller.state, const LoginState(user: testUser));
  });

  test('login sets the user and resets loading', () async {
    final user = await controller.login(login: 'john', password: 'secret');
    expect(user, isNotNull);
    expect(controller.state.user, user);
    expect(controller.state.isLoading, isFalse);
    expect(states.where((s) => s.user != null), hasLength(2));
  });

  test('AuthException is mapped to its message', () async {
    service.error = const AuthException('Invalid login or password.');
    await controller.login(login: 'john', password: 'secret');
    expect(controller.state.error, 'Invalid login or password.');
    expect(controller.state.isLoading, isFalse);
  });

  test('unknown errors are not exposed to the user', () async {
    service.error = const FormatException('Unexpected character');
    await controller.login(login: 'john', password: 'secret');
    expect(controller.state.error, 'Something went wrong. Please try again.');
  });

  test('error is kept until the next operation starts', () async {
    service.error = const AuthException('Invalid login or password.');
    await controller.login(login: 'john', password: 'secret');
    service.error = null;
    await controller.login(login: 'john', password: 'secret');
    expect(controller.state.error, isNull);
    expect(controller.state.user, isNotNull);
  });

  test('logout removes the user', () async {
    await controller.login(login: 'john', password: 'secret');
    await controller.logout();
    expect(controller.state.user, isNull);
  });

  test('listeners are not notified when the state does not change', () async {
    service.savedUser = null;
    await controller.initialize();
    // isLoading: true -> isLoading: false, the user stays null.
    expect(states, const [LoginState(isLoading: true), LoginState()]);
  });
}
