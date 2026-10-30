import 'package:flutter/material.dart';
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
      await Future<void>.delayed(Duration(seconds: 4)); // Emulating app loading vital data
      if (mounted){
        navigator.pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
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
