import 'package:control/control.dart';
import 'package:flutter_dvmatyun/features/login/data/user.dart';
import 'package:flutter_dvmatyun/features/login/domain/auth_exception.dart';
import 'package:flutter_dvmatyun/features/login/domain/user_service_interface.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_state.dart';

final class UserController extends StateController<LoginState>
    with SequentialControllerHandler {
  UserController({required this._userService})
    : super(initialState: const LoginState());

  final IUserService _userService;

  /// Restores the saved user.
  Future<User?> initialize() => _handle(() async {
    if (state.user != null) return;
    final user = await _userService.getUser();
    setState(state.copyWith(user: () => user));
  });

  Future<User?> login({required String login, required String password}) =>
      _handle(() async {
        if (state.user != null) return;
        final user = await _userService.login(login: login, password: password);
        setState(state.copyWith(user: () => user));
      });

  Future<void> logout() => _handle(() async {
    await _userService.logout();
    setState(state.copyWith(user: () => null));
  });

  @override
  void setState(LoginState state) {
    // Do not notify listeners if nothing has changed.
    if (state == this.state) return;
    super.setState(state);
  }

  /// Runs [handler] sequentially with the loading flag set.
  /// The error of the previous operation is reset on start.
  Future<User?> _handle(Future<void> Function() handler) async {
    await handle(
      () async {
        setState(state.copyWith(isLoading: true, error: () => null));
        await handler();
      },
      error: (e, st) async {
        setState(state.copyWith(error: () => _errorMessage(e)));
      },
      done: () async {
        setState(state.copyWith(isLoading: false));
      },
    );

    return state.user;
  }

  /// Maps an error to the message that can be shown to the user.
  static String _errorMessage(Object error) => switch (error) {
    AuthException(:final message) => message,
    _ => 'Something went wrong. Please try again.',
  };
}
