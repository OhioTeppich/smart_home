import 'package:flutter/widgets.dart';

import '../../application/controllers/smart_home_controller.dart';

class SmartHomeScope extends InheritedNotifier<SmartHomeController> {
  const SmartHomeScope({
    required SmartHomeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SmartHomeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SmartHomeScope>();
    assert(scope != null, 'SmartHomeScope is missing above the widget tree.');
    return scope!.notifier!;
  }
}
