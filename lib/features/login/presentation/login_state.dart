import 'package:flutter_dvmatyun/features/login/data/user.dart';

class LoginState {
  const LoginState({
    this.obscurePassword = true,
    this.isLoading = false,
    this.user,
    this.error,
  });

  final bool obscurePassword;
  final bool isLoading;
  final String? error;
  final User? user;

  LoginState copyWith({
    bool? obscurePassword,
    bool? isLoading,
    User? user,
    String? error,
    bool setNullUser = false,
  }) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      user: setNullUser ? null : (user ?? this.user),
      error: error,
    );
  }
}
