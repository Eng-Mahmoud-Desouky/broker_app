import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PaymentGatewayService {
  final SupabaseClient supabaseClient;

  PaymentGatewayService({required this.supabaseClient});

  /// Checks if a given payment gateway is active.
  /// Returns [true] if the gateway exists and `is_active` is true.
  /// Returns [false] otherwise or if an error occurs.
  Future<bool> checkGatewayAvailability(String gatewayCode) async {
    try {
      final response =
          await supabaseClient
              .from('payment_gateways')
              .select('is_active')
              .eq('code', gatewayCode)
              .maybeSingle();

      if (response != null && response['is_active'] != null) {
        return response['is_active'] == true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking gateway availability for $gatewayCode: $e');
      }
      return false;
    }
  }
}
