import 'package:flutter/widgets.dart';

import '../domain/entities/energy_dashboard_data.dart';
import '../domain/entities/energy_point.dart';
import '../domain/repositories/energy_repository.dart';

class EnergyDashboardController extends ChangeNotifier {
  EnergyDashboardController(this._repository);

  final EnergyRepository _repository;
  Period period = Period.day;

  EnergyDashboardData get data => _repository.dashboardData;

  void selectPeriod(Period value) {
    if (period == value) return;
    period = value;
    notifyListeners();
  }
}

class EnergyScope extends InheritedNotifier<EnergyDashboardController> {
  const EnergyScope({
    required EnergyDashboardController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static EnergyDashboardController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EnergyScope>();
    assert(scope != null, 'EnergyScope is missing above this widget.');
    return scope!.notifier!;
  }
}
