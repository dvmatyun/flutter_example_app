import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final appScopeData = AppScopeData.construct();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      data: appScopeData,
      child: MaterialApp(
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        builder: (context, child) {
          return child ?? const Center(child: Text('No root widget'));
        },
      ),
    );
  }
}
