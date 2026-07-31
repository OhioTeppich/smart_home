import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/spotify/application/spotify_bloc.dart';
import 'package:smart_home/features/spotify/application/spotify_event.dart';
import 'package:smart_home/features/spotify/application/spotify_state.dart';
import 'package:smart_home/features/spotify/domain/entities/spotify_now_playing.dart';
import 'package:smart_home/features/spotify/domain/failures/spotify_failure.dart';
import 'package:smart_home/features/spotify/domain/repositories/spotify_repository.dart';
import 'package:smart_home/features/spotify/domain/value_objects/spotify_auth_config.dart';

SpotifyNowPlaying _track({bool isPlaying = true}) => SpotifyNowPlaying(
  track: const SpotifyTrack(
    name: 'Song',
    artistNames: ['Artist'],
    albumName: 'Album',
    albumArtUrl: null,
    durationMs: 200000,
  ),
  isPlaying: isPlaying,
  progressMs: 1000,
);

class _FakeSpotifyRepository implements SpotifyRepository {
  SpotifyAuthConfig? config;
  bool authenticated = false;
  Object? loginError;
  Object? fetchError;
  SpotifyNowPlaying? nowPlaying;
  final calls = <String>[];

  @override
  Future<SpotifyAuthConfig?> loadAuthConfig() async => config;

  @override
  Future<void> saveAuthConfig(SpotifyAuthConfig newConfig) async {
    config = newConfig;
    calls.add('saveAuthConfig');
  }

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<void> login() async {
    calls.add('login');
    if (loginError != null) throw loginError!;
    authenticated = true;
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
    authenticated = false;
  }

  @override
  Future<SpotifyNowPlaying?> fetchCurrentlyPlaying() async {
    calls.add('fetchCurrentlyPlaying');
    if (fetchError != null) throw fetchError!;
    return nowPlaying;
  }
}

void main() {
  late _FakeSpotifyRepository repository;
  late SpotifyBloc bloc;

  setUp(() {
    repository = _FakeSpotifyRepository();
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is SpotifyInitial', () {
    bloc = SpotifyBloc(repository);
    expect(bloc.state, isA<SpotifyInitial>());
  });

  test('SpotifyStarted without a stored session emits Unauthenticated', () async {
    bloc = SpotifyBloc(repository);

    bloc.add(const SpotifyStarted());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SpotifyUnauthenticated>());
  });

  test('SpotifyStarted with a stored session polls and emits Idle when nothing plays', () async {
    repository.authenticated = true;
    bloc = SpotifyBloc(repository);

    bloc.add(const SpotifyStarted());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SpotifyIdle>());
    expect(repository.calls, contains('fetchCurrentlyPlaying'));
  });

  test('SpotifyStarted with a stored session and an active track emits Playing', () async {
    repository.authenticated = true;
    repository.nowPlaying = _track();
    bloc = SpotifyBloc(repository);

    bloc.add(const SpotifyStarted());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SpotifyPlaying>());
    expect((bloc.state as SpotifyPlaying).nowPlaying, _track());
  });

  test('SpotifyConfigSaveRequested with valid input saves and stays unauthenticated', () async {
    bloc = SpotifyBloc(repository);

    bloc.add(
      const SpotifyConfigSaveRequested(
        clientId: 'abc',
        redirectUri: 'http://localhost:8080/auth.html',
      ),
    );
    await Future.delayed(Duration.zero);

    expect(repository.calls, contains('saveAuthConfig'));
    expect(bloc.state, isA<SpotifyUnauthenticated>());
    expect(bloc.state.authConfig?.clientId, 'abc');
  });

  test('SpotifyConfigSaveRequested with invalid input emits an error, no repository call', () async {
    bloc = SpotifyBloc(repository);

    bloc.add(
      const SpotifyConfigSaveRequested(clientId: '  ', redirectUri: ''),
    );
    await Future.delayed(Duration.zero);

    expect(repository.calls, isEmpty);
    final state = bloc.state as SpotifyUnauthenticated;
    expect(state.error, isA<SpotifyInvalidConfigFailure>());
  });

  test('SpotifyLoginRequested success moves to Authenticating then Idle/Playing', () async {
    bloc = SpotifyBloc(repository);

    bloc.add(const SpotifyLoginRequested());
    await Future.delayed(Duration.zero);

    expect(repository.calls, contains('login'));
    expect(bloc.state, isA<SpotifyIdle>());
  });

  test('SpotifyLoginRequested failure surfaces as Unauthenticated with error', () async {
    repository.loginError = const SpotifyAuthCancelledFailure();
    bloc = SpotifyBloc(repository);

    bloc.add(const SpotifyLoginRequested());
    await Future.delayed(Duration.zero);

    final state = bloc.state as SpotifyUnauthenticated;
    expect(state.error, isA<SpotifyAuthCancelledFailure>());
  });

  test('SpotifyLogoutRequested clears session', () async {
    repository.authenticated = true;
    bloc = SpotifyBloc(repository);
    bloc.add(const SpotifyStarted());
    await Future.delayed(Duration.zero);

    bloc.add(const SpotifyLogoutRequested());
    await Future.delayed(Duration.zero);

    expect(repository.calls, contains('logout'));
    expect(bloc.state, isA<SpotifyUnauthenticated>());
  });

  test('a poll failing with SpotifyUnauthenticatedFailure forces re-login', () async {
    repository.authenticated = true;
    bloc = SpotifyBloc(repository);
    bloc.add(const SpotifyStarted());
    await Future.delayed(Duration.zero);

    repository.fetchError = const SpotifyUnauthenticatedFailure();
    bloc.add(const SpotifyPollTicked());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SpotifyUnauthenticated>());
  });

  test('a poll failing with a transient failure keeps the session, surfaces SpotifyError', () async {
    repository.authenticated = true;
    bloc = SpotifyBloc(repository);
    bloc.add(const SpotifyStarted());
    await Future.delayed(Duration.zero);

    repository.fetchError = const SpotifyNetworkFailure();
    bloc.add(const SpotifyPollTicked());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SpotifyError>());

    repository.fetchError = null;
    repository.nowPlaying = _track();
    bloc.add(const SpotifyPollTicked());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<SpotifyPlaying>());
  });
}
