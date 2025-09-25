import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/offer_model.dart';
import '../models/platform_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'home_remote_data_source.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<OfferModel>> getOffers() async {
    try {
      final response = await supabaseClient.from('offers').select('*');

      return (response as List<dynamic>)
          .map((json) => OfferModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch offers: $e');
    }
  }

  @override
  Future<List<PlatformModel>> getPlatforms() async {
    try {
      final response = await supabaseClient
          .from('platforms')
          .select('*')
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => PlatformModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch platforms: $e');
    }
  }

  @override
  Future<List<ProductModel>> getSuggestedProducts() async {
    try {
      final response = await supabaseClient.from('products').select('*');

      return (response).map((json) => ProductModel.fromMap(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch suggested products: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await supabaseClient
          .from('products')
          .select('*')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_in_stock', true)
          .order('name', ascending: true)
          .limit(50);

      return (response as List<dynamic>)
          .map((json) => ProductModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to search products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await supabaseClient
          .from('products')
          .select('*')
          .eq('is_in_stock', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => ProductModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch products: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response =
          await supabaseClient
              .from('products')
              .select('''
            *,
            product_images (
              id,
              product_id,
              image_url,
              position
            ),
            product_colors (
              id,
              product_id,
              color_hex,
              label
            )
          ''')
              .eq('id', id)
              .single();

      return ProductModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch product: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabaseClient
          .from('categories')
          .select('*')
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CategoryModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response = await supabaseClient
          .from('products')
          .select('*, product_categories!inner(category_id)')
          .eq('product_categories.category_id', categoryId)
          .eq('is_in_stock', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => ProductModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch products by category: $e',
      );
    }
  }

  @override
  Future<List<ProductModel>> getSimilarProducts(String productId) async {
    try {
      log('🔍 Starting getSimilarProducts for productId: $productId');

      // Step 1: Get the current product's categories
      log('📋 Querying product_categories for productId: $productId');
      final currentProductCategories = await supabaseClient
          .from('product_categories')
          .select('category_id')
          .eq('product_id', productId);

      log('📋 Found ${currentProductCategories.length} categories for product');

      if (currentProductCategories.isEmpty) {
        log(
          '⚠️ No categories found for product $productId, returning empty list',
        );
        return [];
      }

      // Get the first category ID (we'll use the first category for similarity)
      final categoryId = currentProductCategories.first['category_id'];
      log('🎯 Using category_id: $categoryId for similarity matching');

      // Step 2: Get similar products from the same category
      log('🔎 Querying similar products with category_id: $categoryId');
      final response = await supabaseClient
          .from('products')
          .select('''
            *,
            product_categories!inner(
              category_id,
              categories!inner(name)
            )
          ''')
          .eq('product_categories.category_id', categoryId)
          .neq('id', productId)
          .eq('is_in_stock', true)
          .order('rating', ascending: false)
          .limit(4);

      log(
        '📦 Received ${(response as List).length} similar products from Supabase',
      );

      // Step 3: Process and map the response
      final products =
          (response as List<dynamic>).map((json) {
            log('🔧 Processing product: ${json['id']} - ${json['name']}');

            // Extract category information from the joined data
            final productData = Map<String, dynamic>.from(json);

            // Handle nested category data structure
            if (json['product_categories'] != null &&
                (json['product_categories'] as List).isNotEmpty) {
              final firstCategory = (json['product_categories'] as List).first;

              productData['category_id'] = firstCategory['category_id'];

              if (firstCategory['categories'] != null) {
                productData['category_name'] =
                    firstCategory['categories']['name'];
                log(
                  '📂 Extracted category: ${productData['category_name']} (${productData['category_id']})',
                );
              }
            }

            // Remove the nested objects to avoid conflicts with ProductModel.fromMap
            productData.remove('product_categories');
            productData.remove('categories');

            return ProductModel.fromMap(productData);
          }).toList();

      log('✅ Successfully processed ${products.length} similar products');
      return products;
    } on PostgrestException catch (e) {
      log('❌ Database error in getSimilarProducts: ${e.message}');
      log('❌ Error details: ${e.details}');
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error in getSimilarProducts: $e');
      throw ServerException(message: 'Failed to fetch similar products: $e');
    }
  }
}
