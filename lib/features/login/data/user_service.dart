import 'package:flutter_dvmatyun/features/login/data/user.dart';
import 'package:flutter_dvmatyun/features/login/domain/user_service_interface.dart';

class UserService implements IUserService {
  UserService();

  factory UserService.construct() {
    return UserService();
  }

  User? _user;

  @override
  Future<User?> getUser() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _user;
  }

  @override
  Future<User?> login({required String login, required String password}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return _user = User(id: 'idGuid', login: login, name: 'Name');
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _user = null;
  }
}
