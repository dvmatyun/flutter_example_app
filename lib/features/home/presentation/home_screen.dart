import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
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

  Future<void> _onLogoff() async {
    final appScope = AppScope.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _isLoading = true;
    });
    bool success = false;
    try {
      setState(() {
        _isLoading = true;
      });
      await appScope.userService.logout();
      success = true;
    } on Object catch (e, st) {
      debugPrint(' > Error: $e , st=[$st]');
    }
    if (!mounted) return;

    if (success) {
      navigator.pushReplacementNamed(AppRoutes.login);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home screen'),
        actions: [
          IconButton(
            onPressed: _onLogoff,
            icon: Row(children: [Text('Logout'), Icon(Icons.logout)]),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : Center(child: Text('Home screen body')),
    );
  }
}
