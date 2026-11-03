import 'package:flutter_dvmatyun/features/login/data/user.dart';
import 'package:flutter_dvmatyun/features/login/data/user_api_datasource.dart';
import 'package:flutter_dvmatyun/features/login/data/user_local_datasource.dart';
import 'package:flutter_dvmatyun/features/login/domain/user_service_interface.dart';

const testUser = User(id: '1', name: 'john', login: 'john');

class FakeUserApiDataSource implements IUserApiDataSource {
  Object? loginError;
  int logoutCalls = 0;

  @override
  Future<User> login({required String login, required String password}) async {
    if (loginError case final error?) throw error;
    return User(id: '1', name: login, login: login);
  }

  @override
  Future<void> logout() async => logoutCalls++;
}

class FakeUserLocalDataSource implements IUserLocalDataSource {
  User? user;

  @override
  Future<User?> getUser() async => user;

  @override
  Future<void> saveUser(User user) async => this.user = user;

  @override
  Future<void> clearUser() async => user = null;
}

class FakeUserService implements IUserService {
  User? savedUser;
  Object? error;
  int loginCalls = 0;

  @override
  Future<User?> getUser() async => savedUser;

  @override
  Future<User> login({required String login, required String password}) async {
    loginCalls++;
    if (error case final error?) throw error;
    return savedUser = User(id: '1', name: login, login: login);
  }

  @override
  Future<void> logout() async {
    if (error case final error?) throw error;
    savedUser = null;
  }
}
