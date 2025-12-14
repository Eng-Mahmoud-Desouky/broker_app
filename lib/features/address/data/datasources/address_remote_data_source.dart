import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_address_model.dart';

/// Remote data source for address operations
abstract class AddressRemoteDataSource {
  /// Get all addresses for user
  Future<List<UserAddressModel>> getUserAddresses(String userId);

  /// Add new address
  Future<UserAddressModel> addAddress(UserAddressModel address);

  /// Update existing address
  Future<UserAddressModel> updateAddress(UserAddressModel address);

  /// Delete address
  Future<void> deleteAddress(String addressId);

  /// Set address as default (and unset others)
  Future<void> setDefaultAddress(String userId, String addressId);

  /// Get default address
  Future<UserAddressModel?> getDefaultAddress(String userId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final SupabaseClient supabaseClient;

  AddressRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<UserAddressModel>> getUserAddresses(String userId) async {
    try {
      final response = await supabaseClient
          .from('user_addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) => UserAddressModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to get addresses: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Failed to get addresses: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserAddressModel> addAddress(UserAddressModel address) async {
    try {
      // If setting as default, unset all other defaults first
      if (address.isDefault) {
        await supabaseClient
            .from('user_addresses')
            .update({'is_default': false})
            .eq('user_id', address.userId);
      }

      final response =
          await supabaseClient
              .from('user_addresses')
              .insert(address.toInsertJson())
              .select()
              .single();

      return UserAddressModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to add address: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to add address: ${e.toString()}');
    }
  }

  @override
  Future<UserAddressModel> updateAddress(UserAddressModel address) async {
    try {
      // If setting as default, unset all other defaults first
      if (address.isDefault) {
        await supabaseClient
            .from('user_addresses')
            .update({'is_default': false})
            .eq('user_id', address.userId);
      }

      final response =
          await supabaseClient
              .from('user_addresses')
              .update(address.toUpdateJson())
              .eq('id', address.id)
              .select()
              .single();

      return UserAddressModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to update address: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Failed to update address: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await supabaseClient.from('user_addresses').delete().eq('id', addressId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to delete address: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete address: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      // First, unset all defaults for this user
      await supabaseClient
          .from('user_addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      // Then set the selected address as default
      await supabaseClient
          .from('user_addresses')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', addressId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to set default address: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to set default address: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserAddressModel?> getDefaultAddress(String userId) async {
    try {
      final response =
          await supabaseClient
              .from('user_addresses')
              .select()
              .eq('user_id', userId)
              .eq('is_default', true)
              .maybeSingle();

      if (response == null) return null;
      return UserAddressModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get default address: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get default address: ${e.toString()}',
      );
    }
  }
}
