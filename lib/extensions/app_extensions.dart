import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  Future<T?> pushScreen<T>(Widget screen) {
    return Navigator.of(this)
        .push<T>(MaterialPageRoute<T>(builder: (_) => screen));
  }

  void replaceWith(Widget screen) {
    Navigator.of(this).pushReplacement<void, void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}
