import '../../domain/entities/pricing_settings.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../datasources/pricing_remote_data_source.dart';

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource remoteDataSource;

  PricingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PricingSettings> getPricingSettings() async {
    return await remoteDataSource.getPricingSettings();
  }
}
