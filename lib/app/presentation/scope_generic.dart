// #scope
import 'package:flutter/material.dart';

class ScopeProvider<T> extends InheritedWidget {
  const ScopeProvider({
    required this.data,
    required super.child,
    super.key,
  });

  final T data;

  @override
  bool updateShouldNotify(ScopeProvider oldWidget) {
    return oldWidget.data != data;
  }

  /// example: final brightness = QyreBrightness.of(context);
  static T of<T>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ScopeProvider<T>>()!;
    return scope.data;
  }

  static T ofGet<T>(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ScopeProvider<T>>()!;
    return scope.data;
  }

  static T? ofGetMaybe<T>(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ScopeProvider<T>>();
    return scope?.data;
  }

  static T? maybeOf<T>(BuildContext context, {bool listen = true}) {
    if (listen) {
      final scope = context.dependOnInheritedWidgetOfExactType<ScopeProvider<T>>();
      return scope?.data;
    } else {
      final scope = context.getInheritedWidgetOfExactType<ScopeProvider<T>>();
      return scope?.data;
    }
  }
}