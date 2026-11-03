import 'package:flutter_dvmatyun/features/login/presentation/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  const state = LoginState(user: testUser, error: 'error');

  test('copyWith keeps omitted fields', () {
    expect(state.copyWith(isLoading: true), isNot(same(state)));
    expect(
      state.copyWith(isLoading: true),
      const LoginState(isLoading: true, user: testUser, error: 'error'),
    );
  });

  test('copyWith resets nullable fields explicitly', () {
    expect(
      state.copyWith(user: () => null, error: () => null),
      const LoginState(),
    );
  });

  test('states with equal fields are equal', () {
    expect(state.copyWith(), state);
    expect(state.copyWith().hashCode, state.hashCode);
  });
}
