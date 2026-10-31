import 'dart:convert';

import 'package:flutter_dvmatyun/features/login/data/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IUserLocalDataSource {
  Future<User?> getUser();
  Future<void> saveUser(User user);
  Future<void> clearUser();
}

class UserLocalDataSource implements IUserLocalDataSource {
  UserLocalDataSource();

  static const _userKey = 'user';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<User?> getUser() async {
    final raw = await _prefs.getString(_userKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  @override
  Future<void> saveUser(User user) =>
      _prefs.setString(_userKey, jsonEncode(user.toJson()));

  @override
  Future<void> clearUser() => _prefs.remove(_userKey);
}
