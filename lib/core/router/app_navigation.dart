import 'package:flutter/material.dart';

/// A smarter and reusable navigator utility for managing app navigation.
class AppNavigator {
  /// Push a new page onto the navigation stack with optional arguments.
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push(
      MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }

  /// Replace the current page with a new page with optional arguments.
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).pushReplacement(
      MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }

  /// Clear the navigation stack and push a new page with optional arguments.
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page, {
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(arguments: arguments),
      ),
      (route) => false,
    );
  }

  /// Go back to the previous page.
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  /// Push a named route onto the navigation stack with optional arguments.
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushNamed(routeName, arguments: arguments);
  }

  /// Replace the current page with a named route with optional arguments.
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Clear the navigation stack and push a named route with optional arguments.
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to the root of the navigation stack.
  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
