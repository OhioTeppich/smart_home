import 'package:equatable/equatable.dart';

import 'app_section.dart';

sealed class AppNavigationEvent extends Equatable {
  const AppNavigationEvent();

  @override
  List<Object?> get props => [];
}

class AppNavigationSectionSelected extends AppNavigationEvent {
  const AppNavigationSectionSelected(this.section);

  final AppSection section;

  @override
  List<Object?> get props => [section];
}

class AppNavigationSwiped extends AppNavigationEvent {
  const AppNavigationSwiped(this.pageIndex);

  final int pageIndex;

  @override
  List<Object?> get props => [pageIndex];
}
