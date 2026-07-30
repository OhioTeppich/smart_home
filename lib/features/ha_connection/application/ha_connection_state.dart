import 'package:equatable/equatable.dart';

import '../domain/value_objects/ha_connection_config.dart';

enum HaConnectionTestStatus { idle, inProgress, success, failure }

sealed class HaConnectionState extends Equatable {
  const HaConnectionState();

  @override
  List<Object?> get props => [];
}

class HaConnectionInitial extends HaConnectionState {
  const HaConnectionInitial();
}

class HaConnectionLoadInProgress extends HaConnectionState {
  const HaConnectionLoadInProgress();
}

/// Single settled state covering "unconfigured" (`savedConfig == null`) and
/// "connected" (`savedConfig != null`), plus the transient status of the
/// last connection test triggered from the settings form.
class HaConnectionReady extends HaConnectionState {
  const HaConnectionReady({
    required this.savedConfig,
    this.testStatus = HaConnectionTestStatus.idle,
    this.testMessage,
  });

  final HaConnectionConfig? savedConfig;
  final HaConnectionTestStatus testStatus;
  final String? testMessage;

  HaConnectionReady copyWith({
    HaConnectionConfig? savedConfig,
    bool clearSavedConfig = false,
    HaConnectionTestStatus? testStatus,
    String? testMessage,
    bool clearTestMessage = false,
  }) => HaConnectionReady(
    savedConfig: clearSavedConfig ? null : (savedConfig ?? this.savedConfig),
    testStatus: testStatus ?? this.testStatus,
    testMessage: clearTestMessage ? null : (testMessage ?? this.testMessage),
  );

  @override
  List<Object?> get props => [savedConfig, testStatus, testMessage];
}
