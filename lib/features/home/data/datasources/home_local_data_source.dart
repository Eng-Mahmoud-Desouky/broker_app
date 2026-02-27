import '../../../../core/error/exceptions.dart';
import '../models/offer_model.dart';
import '../models/platform_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../../domain/entities/platform.dart';

abstract class HomeLocalDataSource {
  Future<List<OfferModel>> getFeaturedOffers();
  Future<List<PlatformModel>> getPlatforms();
  Future<List<PlatformModel>> getPlatformsByType(String type);
  Future<List<ProductModel>> getSuggestedProducts();
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> getSimilarProducts(String productId);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  // Dummy data for platforms
  final List<PlatformModel> _dummyPlatforms = [
    // Retail platforms
    PlatformModel(
      id: 'shein',
      name: 'SHEIN',
      logoUrl: 'assets/images/Shein-Logo.png',
      type: PlatformType.retail,
      description: 'أزياء عصرية بأسعار مناسبة',
    ),
    PlatformModel(
      id: 'aliexpress',
      name: 'AliExpress',
      logoUrl: 'assets/images/Aliexpress-Logo.jpg',
      type: PlatformType.retail,
      description: 'تسوق بالتجزئة من الصين',
    ),
    PlatformModel(
      id: 'amazon',
      name: 'Amazon',
      logoUrl: 'assets/images/Amazon-Logo.png',
      type: PlatformType.retail,
      description: 'أكبر متجر إلكتروني في العالم',
    ),
    // Wholesale platforms
    PlatformModel(
      id: 'alibaba',
      name: 'Alibaba',
      logoUrl: 'assets/images/Alibaba-Logo.jpg',
      type: PlatformType.wholesale,
      description: 'منصة التجارة الإلكترونية للجملة',
    ),
    PlatformModel(
      id: 'taobao',
      name: 'Taobao',
      logoUrl: 'assets/images/Taobao-Logo.png',
      type: PlatformType.wholesale,
      description: 'منصة التسوق بالجملة من الصين',
    ),
  ];

  @override
  Future<List<PlatformModel>> getPlatforms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyPlatforms;
  }

  @override
  Future<List<PlatformModel>> getPlatformsByType(String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final platformType =
        type == 'retail' ? PlatformType.retail : PlatformType.wholesale;
    return _dummyPlatforms
        .where((platform) => platform.type == platformType)
        .toList();
  }

  @override
  Future<List<OfferModel>> getFeaturedOffers() async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }

  @override
  Future<List<ProductModel>> getSuggestedProducts() async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }

  @override
  Future<List<ProductModel>> getSimilarProducts(String productId) async {
    throw const CacheException(message: 'لا يوجد اتصال بالإنترنت');
  }
}
