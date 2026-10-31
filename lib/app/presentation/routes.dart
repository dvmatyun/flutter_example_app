import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/features/game/presentation/game_rect_screen.dart';
import 'package:flutter_dvmatyun/features/home/presentation/home_screen.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_screen.dart';
import 'package:flutter_dvmatyun/features/splash/presentation/splash_screen.dart';

mixin AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String gameRect = '/gamerect';

  static final routes = _getRoutes();

  static Map<String, WidgetBuilder> _getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      gameRect: (context) => const GameRectScreen(),
    };
  }
}