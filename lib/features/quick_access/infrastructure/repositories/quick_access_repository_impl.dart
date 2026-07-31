import '../../domain/repositories/quick_access_repository.dart';
import '../data_sources/quick_access_local_data_source.dart';

class QuickAccessRepositoryImpl implements QuickAccessRepository {
  QuickAccessRepositoryImpl(this._localDataSource);

  final QuickAccessLocalDataSource _localDataSource;

  @override
  Future<List<String>> loadDeviceIds() => _localDataSource.readIds();

  @override
  Future<void> saveDeviceIds(List<String> deviceIds) =>
      _localDataSource.writeIds(deviceIds);
}
