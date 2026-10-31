import 'package:control/control.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/features/login/data/user.dart';
import 'package:flutter_dvmatyun/features/login/domain/user_service_interface.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_state.dart';

final class UserController extends StateController<LoginState>
    with SequentialControllerHandler {
  UserController({required this._userService})
    : super(initialState: LoginState());

  factory UserController.construct(AppScopeData appScope) {
    return UserController(userService: appScope.userService);
  }

  final IUserService _userService;

  Future<void> togglePasswordVisibility() async {
    setState(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<User?> initialize() async {
    await handle(
      () async {
        if (state.user != null) return;
        setState(state.copyWith(isLoading: true));
        final user = await _userService.getUser();
        setState(state.copyWith(user: user));
      },
      error: (e, st) async {
        setState(state.copyWith(error: e.toString()));
      },
      done: () async {
        setState(state.copyWith(isLoading: false));
      },
    );

    return state.user;
  }

  Future<User?> login({required String login, required String password}) async {
    
    await handle(
      () async {
        if (login.isEmpty || password.isEmpty) {
          throw Exception('Login and pasword must not be empty!');
        }
        if (state.user != null) return;
        setState(state.copyWith(isLoading: true));
        final user = await _userService.login(login: login, password: password);
        setState(state.copyWith(user: user));
      },
      error: (e, st) async {
        setState(state.copyWith(error: e.toString()));
      },
      done: () async {
        setState(state.copyWith(isLoading: false));
      },
    );

    return state.user;
  }

  Future<void> logout() async {
    await handle(
      () async {
        setState(state.copyWith(isLoading: true));
        await _userService.logout();
        setState(state.copyWith(setNullUser: true));
      },
      error: (e, st) async {
        setState(state.copyWith(error: e.toString()));
      },
      done: () async {
        setState(state.copyWith(isLoading: false));
      },
    );
  }
}
