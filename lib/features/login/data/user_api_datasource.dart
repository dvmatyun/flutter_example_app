import 'package:flutter_dvmatyun/features/login/data/user.dart';

abstract interface class IUserApiDataSource {
  Future<User> login({required String login, required String password});
  Future<void> logout();
}

class UserApiDataSource implements IUserApiDataSource {
  const UserApiDataSource();

  @override
  Future<User> login({required String login, required String password}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (login.isEmpty || password.isEmpty) {
      throw const FormatException('Login and password must not be empty!!!');
    }

    return User(id: login.hashCode.toString(), login: login, name: login);
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
