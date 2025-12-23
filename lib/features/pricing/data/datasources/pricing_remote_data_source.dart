import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pricing_settings_model.dart';

abstract class PricingRemoteDataSource {
  Future<PricingSettingsModel> getPricingSettings();
}

class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final SupabaseClient supabaseClient;

  PricingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<PricingSettingsModel> getPricingSettings() async {
    final response =
        await supabaseClient
            .from('pricing_settings')
            .select()
            .order('updated_at', ascending: false)
            .limit(1)
            .single();

    return PricingSettingsModel.fromJson(response);
  }
}
