import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/currency/currency_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWalletBalance(String userId);
  Future<List<WalletTransactionModel>> getTransactionHistory(
    String userId, {
    int? limit,
    int? offset,
  });
  Future<Map<String, dynamic>> createTopUpSession({
    required String userId,
    required double amount,
  });
  Future<WalletTransactionModel> getTransactionById(String transactionId);
  Stream<WalletModel> watchWalletBalance(String userId);
  Stream<List<WalletTransactionModel>> watchTransactionHistory(String userId);
  Future<void> deductBalance({
    required String userId,
    required double amount,
    required String orderId,
  });
  Future<void> cancelTopUpSession(String transactionId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient supabaseClient;

  WalletRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<WalletModel> getWalletBalance(String userId) async {
    try {
      final response =
          await supabaseClient
              .from('wallets')
              .select('*')
              .eq('user_id', userId)
              .single();

      return WalletModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch wallet balance: $e');
    }
  }

  @override
  Future<List<WalletTransactionModel>> getTransactionHistory(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = supabaseClient
          .from('wallet_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      return (response as List<dynamic>)
          .map(
            (json) =>
                WalletTransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch transaction history: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createTopUpSession({
    required String userId,
    required double amount,
  }) async {
    try {
      final response = await supabaseClient.functions
          .invoke('zaincash-topup', body: {'user_id': userId, 'amount': amount})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ServerException(
                message:
                    'انتهت مهلة الاتصال بخدمة الدفع. يرجى المحاولة مرة أخرى.',
              );
            },
          );

      if (response.data == null) {
        throw ServerException(message: 'لم يتم استلام رد من خدمة الدفع');
      }

      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      throw ServerException(
        message: 'خطأ في خدمة الدفع: ${e.details ?? e.toString()}',
      );
    } on ServerException {
      rethrow; // Re-throw ServerException with original message
    } catch (e) {
      throw ServerException(
        message: 'فشل الاتصال بخدمة الدفع. تأكد من اتصالك بالإنترنت: $e',
      );
    }
  }

  @override
  Future<WalletTransactionModel> getTransactionById(
    String transactionId,
  ) async {
    try {
      final response =
          await supabaseClient
              .from('wallet_transactions')
              .select('*')
              .eq('id', transactionId)
              .single();

      return WalletTransactionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch transaction: $e');
    }
  }

  @override
  Stream<WalletModel> watchWalletBalance(String userId) {
    return supabaseClient
        .from('wallets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) {
          if (data.isEmpty) {
            throw const ServerException(message: 'Wallet not found');
          }
          return WalletModel.fromJson(data.first);
        })
        .handleError((error) {
          throw ServerException(
            message: 'Failed to watch wallet balance: $error',
          );
        });
  }

  @override
  Stream<List<WalletTransactionModel>> watchTransactionHistory(String userId) {
    return supabaseClient
        .from('wallet_transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .map((json) => WalletTransactionModel.fromJson(json))
              .toList();
        })
        .handleError((error) {
          throw ServerException(
            message: 'Failed to watch transaction history: $error',
          );
        });
  }

  @override
  Future<void> deductBalance({
    required String userId,
    required double amount,
    required String orderId,
  }) async {
    try {
      // 1. Get current balance
      final walletResponse =
          await supabaseClient
              .from('wallets')
              .select('balance')
              .eq('user_id', userId)
              .single();

      final currentBalance = CurrencyService.toDouble(
        walletResponse['balance'],
      );
      final newBalance = currentBalance - amount;

      // 2. Update wallet balance
      await supabaseClient
          .from('wallets')
          .update({'balance': newBalance})
          .eq('user_id', userId);

      // 3. Create transaction record
      await supabaseClient.from('wallet_transactions').insert({
        'user_id': userId,
        'amount': amount,
        'type': 'purchase',
        'status': 'success',
        'metadata': {
          'order_id': orderId,
          'description': 'Purchase for order $orderId',
        },
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to deduct balance: $e');
    }
  }

  @override
  Future<void> cancelTopUpSession(String transactionId) async {
    try {
      // 1. Verify it's a pending topup transaction before deleting
      final txResp =
          await supabaseClient
              .from('wallet_transactions')
              .select('status, type')
              .eq('provider_reference', transactionId)
              .maybeSingle();

      if (txResp == null) return;

      final status = txResp['status'] as String;
      final type = txResp['type'] as String;

      if (status == 'pending' && type == 'topup') {
        if (kDebugMode) {
          debugPrint(
            '🗑️ Deleting cancelled topup transaction: $transactionId',
          );
        }
        await supabaseClient
            .from('wallet_transactions')
            .delete()
            .eq('provider_reference', transactionId);
      }
    } catch (e) {
      // We don't want to throw here to avoid interrupting the UI flow
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cancel topup session: $e');
      }
    }
  }
}
