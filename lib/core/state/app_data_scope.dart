import 'package:finalproject/core/state/app_data_controller.dart';
import 'package:flutter/widgets.dart';

class AppDataScope extends InheritedNotifier<AppDataController> {
  const AppDataScope({
    required AppDataController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppDataController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDataScope>();
    assert(scope != null, 'No AppDataScope found in this context.');
    return scope!.notifier!;
  }

  static AppDataController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppDataScope>();
    assert(scope != null, 'No AppDataScope found in this context.');
    return scope!.notifier!;
  }
}
