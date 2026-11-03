import 'package:flutter/widgets.dart';
import 'package:flutter_dvmatyun/features/login/data/user_service.dart';
import 'package:flutter_dvmatyun/features/login/domain/user_service_interface.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({required this.data, required super.child, super.key});

  final AppScopeData data;

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    final shouldNotify = oldWidget.data != data;
    return shouldNotify;
  }

  static AppScopeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>()!;
    return scope.data;
  }

  static AppScopeData ofGet(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>()!;
    return scope.data;
  }

  static AppScopeData? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    return scope?.data;
  }
}

class AppScopeData {
  const AppScopeData({required this.userService, required this.userController});

  factory AppScopeData.construct() {
    final userService = UserService.construct();
    return AppScopeData(
      userService: userService,
      userController: UserController(userService: userService),
    );
  }

  final IUserService userService;
  final UserController userController;
}
