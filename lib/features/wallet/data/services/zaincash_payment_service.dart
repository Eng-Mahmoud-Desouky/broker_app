import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../presentation/pages/payment_webview_screen.dart';

class ZainCashPaymentService {
  final WalletRepository walletRepository;
  final SupabaseClient supabaseClient;

  ZainCashPaymentService({
    required this.walletRepository,
    required this.supabaseClient,
  });

  Future<void> startZainCashPayment({
    required BuildContext context,
    required String userId,
    required double amount,
  }) async {
    try {
      // 1. Show loading indicator
      _showLoadingDialog(context);

      // 2. Call Supabase Edge Function to initiate payment
      final response = await supabaseClient.functions.invoke(
        'zaincash-topup',
        body: {'user_id': userId, 'amount': amount},
      );

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (response.data == null || response.data['redirectUrl'] == null) {
        throw Exception('فشل بدء عملية الدفع: لم يتم استلام رابط التوجيه');
      }

      final String redirectUrl = response.data['redirectUrl'];

      // Navigate to the updated WebView screen.
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => PaymentWebViewScreen(
                  paymentUrl: redirectUrl,
                  userId: userId,
                  transactionId: '', // v2 uses externalReferenceId from backend
                ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }
}
