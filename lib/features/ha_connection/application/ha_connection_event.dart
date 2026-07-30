import 'package:equatable/equatable.dart';

sealed class HaConnectionEvent extends Equatable {
  const HaConnectionEvent();

  @override
  List<Object?> get props => [];
}

class HaConnectionStarted extends HaConnectionEvent {
  const HaConnectionStarted();
}

class HaConnectionTestRequested extends HaConnectionEvent {
  const HaConnectionTestRequested({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  @override
  List<Object?> get props => [baseUrl, token];
}

class HaConnectionSaveRequested extends HaConnectionEvent {
  const HaConnectionSaveRequested({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  @override
  List<Object?> get props => [baseUrl, token];
}

class HaConnectionCleared extends HaConnectionEvent {
  const HaConnectionCleared();
}
