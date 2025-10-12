import 'package:supabase_flutter/supabase_flutter.dart';

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
  Future<Map<String, dynamic>> createTopUpTransaction({
    required String userId,
    required int amount,
  });
  Future<WalletTransactionModel> getTransactionById(String transactionId);
  Stream<WalletModel> watchWalletBalance(String userId);
  Stream<List<WalletTransactionModel>> watchTransactionHistory(String userId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient supabaseClient;

  WalletRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<WalletModel> getWalletBalance(String userId) async {
    try {
      final response = await supabaseClient
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
          .map((json) => WalletTransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch transaction history: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createTopUpTransaction({
    required String userId,
    required int amount,
  }) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'zaincash-topup',
        body: {
          'user_id': userId,
          'amount': amount.toString(),
        },
      );

      if (response.data == null) {
        throw ServerException(message: 'No response from payment service');
      }

      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      throw ServerException(message: 'Payment service error: ${e.details}');
    } catch (e) {
      throw ServerException(message: 'Failed to create top-up transaction: $e');
    }
  }

  @override
  Future<WalletTransactionModel> getTransactionById(String transactionId) async {
    try {
      final response = await supabaseClient
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
          throw ServerException(message: 'Failed to watch wallet balance: $error');
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
          throw ServerException(message: 'Failed to watch transaction history: $error');
        });
  }
}
