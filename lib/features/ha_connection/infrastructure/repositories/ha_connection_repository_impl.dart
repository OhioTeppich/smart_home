import '../../../../core/home_assistant/ha_client_exceptions.dart';
import '../../../../core/home_assistant/ha_rest_client.dart';
import '../../domain/failures/ha_connection_failure.dart';
import '../../domain/repositories/ha_connection_repository.dart';
import '../../domain/value_objects/ha_connection_config.dart';
import '../data_sources/ha_connection_local_data_source.dart';

class HaConnectionRepositoryImpl implements HaConnectionRepository {
  HaConnectionRepositoryImpl(this._localDataSource, [HaRestClient? restClient])
    : _restClient = restClient ?? HaRestClient();

  final HaConnectionLocalDataSource _localDataSource;
  final HaRestClient _restClient;

  @override
  Future<HaConnectionConfig?> loadConfig() async {
    final stored = await _localDataSource.read();
    if (stored == null) return null;
    return HaConnectionConfig(baseUrl: stored.baseUrl, token: stored.token);
  }

  @override
  Future<void> saveConfig(HaConnectionConfig config) =>
      _localDataSource.write(baseUrl: config.baseUrl, token: config.token);

  @override
  Future<void> clearConfig() => _localDataSource.clear();

  @override
  Future<void> testConnection(HaConnectionConfig config) async {
    try {
      await _restClient.ping(baseUrl: config.baseUrl, token: config.token);
    } on HaAuthException {
      throw const HaConnectionUnauthorizedFailure();
    } on HaTimeoutException {
      throw const HaConnectionTimedOutFailure();
    } on HaConnectionException {
      throw const HaConnectionUnreachableFailure();
    } on HaProtocolException catch (error) {
      throw HaConnectionUnexpectedFailure(error.message);
    }
  }
}
