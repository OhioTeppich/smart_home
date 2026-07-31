import 'package:equatable/equatable.dart';

import 'app_section.dart';

class AppNavigationState extends Equatable {
  const AppNavigationState(this.section);

  final AppSection section;

  @override
  List<Object?> get props => [section];
}
