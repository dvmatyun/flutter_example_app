import 'package:flutter_dvmatyun/features/login/data/user_service.dart';
import 'package:flutter_dvmatyun/features/login/domain/auth_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeUserApiDataSource api;
  late FakeUserLocalDataSource local;
  late UserService service;

  setUp(() {
    api = FakeUserApiDataSource();
    local = FakeUserLocalDataSource();
    service = UserService(apiDataSource: api, localDataSource: local);
  });

  test('getUser returns the locally saved user', () async {
    expect(await service.getUser(), isNull);
    local.user = testUser;
    expect(await service.getUser(), testUser);
  });

  test('login saves the user locally', () async {
    final user = await service.login(login: 'john', password: 'secret');
    expect(user.login, 'john');
    expect(local.user, user);
  });

  test('failed login does not save the user', () async {
    api.loginError = const AuthException('Invalid login or password.');
    await expectLater(
      service.login(login: 'john', password: 'secret'),
      throwsA(isA<AuthException>()),
    );
    expect(local.user, isNull);
  });

  test('logout clears the local user', () async {
    local.user = testUser;
    await service.logout();
    expect(api.logoutCalls, 1);
    expect(local.user, isNull);
  });
}
