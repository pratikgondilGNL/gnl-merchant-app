import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension BuildContextExtensions on BuildContext {
  // MediaQuery helpers
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get topPadding => MediaQuery.of(this).viewPadding.top;
  double get bottomPadding => MediaQuery.of(this).viewPadding.bottom;

  // GoRouter shortcuts
  void pushNamed(String name, {Map<String, String> pathParameters = const {}, Map<String, dynamic>? extra}) =>
      GoRouter.of(this).pushNamed(name, pathParameters: pathParameters, extra: extra);

  void goNamed(String name, {Map<String, String> pathParameters = const {}, Map<String, dynamic>? extra}) =>
      GoRouter.of(this).goNamed(name, pathParameters: pathParameters, extra: extra);

  void pop() => GoRouter.of(this).pop();
}
