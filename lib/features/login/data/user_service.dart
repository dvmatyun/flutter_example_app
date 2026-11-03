import 'package:flutter_dvmatyun/features/login/data/user.dart';
import 'package:flutter_dvmatyun/features/login/data/user_api_datasource.dart';
import 'package:flutter_dvmatyun/features/login/data/user_local_datasource.dart';
import 'package:flutter_dvmatyun/features/login/domain/user_service_interface.dart';

class UserService implements IUserService {
  const UserService({
    required this._apiDataSource,
    required this._localDataSource,
  });

  factory UserService.construct() {
    return UserService(
      apiDataSource: const UserApiDataSource(),
      localDataSource: UserLocalDataSource(),
    );
  }

  final IUserApiDataSource _apiDataSource;
  final IUserLocalDataSource _localDataSource;

  @override
  Future<User?> getUser() => _localDataSource.getUser();

  @override
  Future<User> login({required String login, required String password}) async {
    final user = await _apiDataSource.login(login: login, password: password);
    await _localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _apiDataSource.logout();
    await _localDataSource.clearUser();
  }
}
