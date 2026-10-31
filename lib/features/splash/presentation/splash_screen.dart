import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';

/// {@template splash_screen}
/// SplashScreen widget.
/// {@endtemplate}
class SplashScreen extends StatefulWidget {
  /// {@macro splash_screen}
  const SplashScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// State for widget SplashScreen.
class _SplashScreenState extends State<SplashScreen> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigator = Navigator.of(context);
      final appScope = AppScope.of(context);
      await appScope.userController.initialize();
      if (!mounted) return;
      if (appScope.userController.state.user == null) {
        navigator.pushReplacementNamed(AppRoutes.login);
      } else {
        navigator.pushReplacementNamed(AppRoutes.home);
      }
    });
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Splash screen')),
      body: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
