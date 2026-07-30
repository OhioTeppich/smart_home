import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/rooms/application/smart_home_bloc.dart';
import 'package:smart_home/features/rooms/application/smart_home_event.dart';
import 'package:smart_home/features/rooms/application/smart_home_state.dart';
import 'package:smart_home/features/rooms/domain/entities/smart_home_device.dart';
import 'package:smart_home/features/rooms/domain/failures/smart_home_failure.dart';
import 'package:smart_home/features/rooms/domain/repositories/smart_home_repository.dart';

SmartHomeDevice _lamp({String id = 'light.a', String? roomId = 'livingRoom'}) =>
    SmartHomeDevice(
      id: id,
      name: 'Lampe',
      type: SmartHomeDeviceType.bulb,
      status: 'Online',
      powerWatts: 9,
      dailyKwh: .1,
      lastUpdated: 'gerade eben',
      roomId: roomId,
    );

class _FakeSmartHomeRepository implements SmartHomeRepository {
  final _controller = StreamController<List<SmartHomeDevice>>.broadcast();
  final calls = <String>[];
  Object? toggleError;

  void pushDevices(List<SmartHomeDevice> devices) => _controller.add(devices);
  void pushError(Object error) => _controller.addError(error);

  @override
  Stream<List<SmartHomeDevice>> watchDevices() => _controller.stream;

  @override
  Future<List<SmartHomeDevice>> fetchDevices() async => const [];

  @override
  Future<void> toggleDevice(String id, bool isOn) async {
    calls.add('toggle:$id:$isOn');
    if (toggleError != null) throw toggleError!;
  }

  @override
  Future<void> assignDeviceToRoom(String id, String? roomId) async {
    calls.add('assign:$id:$roomId');
  }

  @override
  Future<void> placeDevice(String id, String roomId, double x, double y) async {
    calls.add('place:$id:$roomId:$x:$y');
  }

  @override
  Future<void> removeFromView(String id) async {
    calls.add('remove:$id');
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  late _FakeSmartHomeRepository repository;
  late SmartHomeBloc bloc;

  setUp(() {
    repository = _FakeSmartHomeRepository();
    bloc = SmartHomeBloc(repository);
  });

  tearDown(() async {
    await bloc.close();
    await repository.dispose();
  });

  test('initial state is SmartHomeInitial', () {
    expect(bloc.state, const SmartHomeInitial());
  });

  test('SmartHomeStarted subscribes and forwards devices as SmartHomeConnected', () async {
    final states = <SmartHomeState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const SmartHomeStarted());
    await Future.delayed(Duration.zero);
    repository.pushDevices([_lamp()]);
    await Future.delayed(Duration.zero);

    expect(states.first, const SmartHomeLoading());
    final connected = states.last as SmartHomeConnected;
    expect(connected.devices, hasLength(1));
    expect(connected.isPlacing, isFalse);
    await sub.cancel();
  });

  test('a stream error surfaces as SmartHomeError', () async {
    bloc.add(const SmartHomeStarted());
    await Future.delayed(Duration.zero);

    repository.pushError(const SmartHomeConnectionFailure());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SmartHomeError>());
    expect(
      (bloc.state as SmartHomeError).message,
      const SmartHomeConnectionFailure().message,
    );
  });

  test('SmartHomeDeviceToggled calls the repository', () async {
    bloc.add(const SmartHomeDeviceToggled('light.a', true));
    await Future.delayed(Duration.zero);

    expect(repository.calls, ['toggle:light.a:true']);
  });

  test('a failing toggle surfaces as SmartHomeError', () async {
    repository.toggleError = const SmartHomeUnauthorizedFailure();

    bloc.add(const SmartHomeDeviceToggled('light.a', true));
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SmartHomeError>());
  });

  test('placement flow: started -> confirmed calls placeDevice with pending device+room', () async {
    bloc.add(const SmartHomeStarted());
    await Future.delayed(Duration.zero);
    repository.pushDevices([_lamp()]);
    await Future.delayed(Duration.zero);

    bloc.add(SmartHomePlacementStarted(_lamp(id: 'light.b', roomId: null), 'kitchen'));
    await Future.delayed(Duration.zero);
    expect((bloc.state as SmartHomeConnected).isPlacing, isTrue);

    bloc.add(const SmartHomePlacementConfirmed(.5, .6));
    await Future.delayed(Duration.zero);

    expect(repository.calls, ['place:light.b:kitchen:0.5:0.6']);
    expect((bloc.state as SmartHomeConnected).isPlacing, isFalse);
  });

  test('SmartHomePlacementCancelled clears pending placement without a repository call', () async {
    bloc.add(const SmartHomeStarted());
    await Future.delayed(Duration.zero);
    repository.pushDevices([_lamp()]);
    await Future.delayed(Duration.zero);

    bloc.add(SmartHomePlacementStarted(_lamp(id: 'light.b', roomId: null), 'kitchen'));
    await Future.delayed(Duration.zero);

    bloc.add(const SmartHomePlacementCancelled());
    await Future.delayed(Duration.zero);

    expect((bloc.state as SmartHomeConnected).isPlacing, isFalse);
    expect(repository.calls, isEmpty);
  });

  test('SmartHomeDeviceAssignedToRoom and SmartHomeDeviceRemovedFromView call the repository', () async {
    bloc.add(const SmartHomeDeviceAssignedToRoom('light.a', 'bedroom'));
    bloc.add(const SmartHomeDeviceRemovedFromView('light.a'));
    await Future.delayed(Duration.zero);

    expect(repository.calls, ['assign:light.a:bedroom', 'remove:light.a']);
  });
}
