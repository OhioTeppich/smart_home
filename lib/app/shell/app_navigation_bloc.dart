import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_navigation_event.dart';
import 'app_navigation_state.dart';
import 'app_section.dart';

class AppNavigationBloc extends Bloc<AppNavigationEvent, AppNavigationState> {
  AppNavigationBloc() : super(const AppNavigationState(AppSection.home)) {
    on<AppNavigationSectionSelected>(
      (event, emit) => emit(AppNavigationState(event.section)),
    );
  }
}
