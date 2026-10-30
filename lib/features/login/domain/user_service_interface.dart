import 'package:flutter_dvmatyun/features/login/data/user.dart';

abstract class IUserService {
  Future<User?> getUser();
  Future<User?> login({required String login, required String password});
  Future<void> logout();
}
