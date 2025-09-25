import '../models/offer_model.dart';
import '../models/platform_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<OfferModel>> getOffers();
  Future<List<PlatformModel>> getPlatforms();
  Future<List<ProductModel>> getSuggestedProducts();
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> getSimilarProducts(String productId);
}
