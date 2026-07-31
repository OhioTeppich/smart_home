import 'package:equatable/equatable.dart';

import 'app_section.dart';

class AppNavigationState extends Equatable {
  const AppNavigationState(this.section);

  final AppSection section;

  int get pageIndex => kTopLevelSections.indexOf(section);

  @override
  List<Object?> get props => [section];
}
