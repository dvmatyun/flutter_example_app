import 'package:flutter/foundation.dart';
import 'package:flutter_dvmatyun/features/login/data/user.dart';

/// State of the authentication.
///
/// [error] is the message of the last failed operation. It is kept until
/// the next operation starts, so listeners should react to its change
/// rather than to its presence.
@immutable
class LoginState {
  const LoginState({this.isLoading = false, this.user, this.error});

  final bool isLoading;
  final User? user;
  final String? error;

  /// Nullable fields are passed as getters, so they can be reset explicitly:
  /// `state.copyWith(user: () => null)`.
  /// Omitted fields keep their current values.
  LoginState copyWith({
    bool? isLoading,
    ValueGetter<User?>? user,
    ValueGetter<String?>? error,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user != null ? user() : this.user,
      error: error != null ? error() : this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginState &&
          isLoading == other.isLoading &&
          user == other.user &&
          error == other.error;

  @override
  int get hashCode => Object.hash(isLoading, user, error);
}
