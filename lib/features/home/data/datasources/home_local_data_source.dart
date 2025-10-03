import '../models/offer_model.dart';
import '../models/platform_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/product_image_model.dart';
import '../models/product_color_model.dart';
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
  // Dummy data for offers
  final List<OfferModel> _dummyOffers = [
    OfferModel(
      id: '1',
      title: 'خصم 50% على جميع المنتجات',
      description: 'عرض محدود لفترة قصيرة',
      imageUrl: 'https://picsum.photos/400/200?random=10',
      discountPercentage: '50%',
      validUntil: DateTime.now().add(const Duration(days: 7)),
      actionUrl: '/offers/1',
    ),
    OfferModel(
      id: '2',
      title: 'شحن مجاني للطلبات فوق 100 دولار',
      description: 'استمتع بالشحن المجاني',
      imageUrl: 'https://picsum.photos/400/200?random=11',
      discountPercentage: null,
      validUntil: DateTime.now().add(const Duration(days: 14)),
      actionUrl: '/offers/2',
    ),
    OfferModel(
      id: '3',
      title: 'منتجات جديدة من أمازون',
      description: 'اكتشف أحدث المنتجات',
      imageUrl: 'https://picsum.photos/400/200?random=12',
      discountPercentage: '30%',
      validUntil: DateTime.now().add(const Duration(days: 10)),
      actionUrl: '/offers/3',
    ),
  ];

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
      id: 'taobao',
      name: 'Taobao',
      logoUrl: 'assets/images/Taobao-Logo.png',
      type: PlatformType.retail,
      description: 'منصة التسوق الصينية الرائدة',
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
      id: 'aliexpress',
      name: 'AliExpress',
      logoUrl: 'assets/images/Aliexpress-Logo.jpg',
      type: PlatformType.wholesale,
      description: 'تسوق بالجملة من الصين',
    ),
  ];

  // @override
  // Future<List<OfferModel>> getFeaturedOffers() async {
  //   // Simulate network delay
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   return _dummyOffers;
  // }

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
  Future<List<ProductModel>> getSuggestedProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _getDummyProducts();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simple search simulation
    final products = _getDummyProducts();
    if (query.isEmpty) return products;

    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Dummy data for products
  List<ProductModel> _getDummyProducts() {
    return [
      ProductModel(
        id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        name: 'هاتف ذكي أندرويد',
        description: 'هاتف ذكي بمواصفات عالية',
        mainImageUrl: 'https://picsum.photos/200/200?random=1',
        price: 299.99,
        currency: 'USD',
        originalPrice: 399.99,
        rating: 4.5,
        reviewCount: 1250,
        platformId: 'amazon',
        platformName: 'Amazon',
        categoryId: 'electronics',
        categoryName: 'إلكترونيات',
        specifications: {
          'الشاشة': '6.1 بوصة',
          'المعالج': 'Snapdragon 888',
          'الذاكرة': '8 جيجابايت',
          'التخزين': '128 جيجابايت',
          'الكاميرا': '48 ميجابكسل',
          'البطارية': '4000 مللي أمبير',
        },
        images: [
          ProductImageModel(
            id: 'img1',
            productId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            imageUrl: 'https://picsum.photos/400/400?random=1',
            position: 0,
          ),
          ProductImageModel(
            id: 'img2',
            productId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            imageUrl: 'https://picsum.photos/400/400?random=11',
            position: 1,
          ),
          ProductImageModel(
            id: 'img3',
            productId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            imageUrl: 'https://picsum.photos/400/400?random=12',
            position: 2,
          ),
        ],
        colors: [
          ProductColorModel(
            id: 'color1',
            productId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            colorHex: '#000000',
            label: 'أسود',
          ),
          ProductColorModel(
            id: 'color2',
            productId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            colorHex: '#FFFFFF',
            label: 'أبيض',
          ),
          ProductColorModel(
            id: 'color3',
            productId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            colorHex: '#FF0000',
            label: 'أحمر',
          ),
        ],
      ),
      ProductModel(
        id: 'b2c3d4e5-f6g7-8901-bcde-f23456789012',
        name: 'فستان صيفي أنيق',
        description: 'فستان مناسب للصيف',
        mainImageUrl: 'https://picsum.photos/200/200?random=2',
        price: 29.99,
        currency: 'USD',
        originalPrice: 49.99,
        rating: 4.2,
        reviewCount: 890,
        platformId: 'shein',
        platformName: 'SHEIN',
        categoryId: 'clothing',
        categoryName: 'ملابس',
      ),
      ProductModel(
        id: 'c3d4e5f6-g7h8-9012-cdef-345678901234',
        name: 'ساعة ذكية رياضية',
        description: 'ساعة ذكية لتتبع اللياقة',
        mainImageUrl: 'https://picsum.photos/200/200?random=3',
        price: 149.99,
        currency: 'USD',
        rating: 4.7,
        reviewCount: 2100,
        platformId: 'aliexpress',
        platformName: 'AliExpress',
        categoryId: 'electronics',
        categoryName: 'إلكترونيات',
      ),
      ProductModel(
        id: 'd4e5f6g7-h8i9-0123-defg-456789012345',
        name: 'حقيبة يد نسائية',
        description: 'حقيبة أنيقة للاستخدام اليومي',
        mainImageUrl: 'https://picsum.photos/200/200?random=4',
        price: 79.99,
        currency: 'USD',
        originalPrice: 120.00,
        rating: 4.3,
        reviewCount: 567,
        platformId: 'taobao',
        platformName: 'Taobao',
        categoryId: 'accessories',
        categoryName: 'إكسسوارات',
      ),
      ProductModel(
        id: 'e5f6g7h8-i9j0-1234-efgh-567890123456',
        name: 'سماعات لاسلكية',
        description: 'سماعات بلوتوث عالية الجودة',
        mainImageUrl: 'https://picsum.photos/200/200?random=5',
        price: 89.99,
        currency: 'USD',
        rating: 4.6,
        reviewCount: 1890,
        platformId: 'alibaba',
        platformName: 'Alibaba',
        categoryId: 'electronics',
        categoryName: 'إلكترونيات',
      ),
    ];
  }

  @override
  Future<List<OfferModel>> getFeaturedOffers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyOffers;
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _getDummyProducts();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final products = _getDummyProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      throw Exception('Product not found');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const CategoryModel(id: '1', name: 'إلكترونيات'),
      const CategoryModel(id: '2', name: 'ملابس'),
      const CategoryModel(id: '3', name: 'منزل وحديقة'),
      const CategoryModel(id: '4', name: 'رياضة'),
      const CategoryModel(id: '5', name: 'جمال وعناية'),
    ];
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // For demo purposes, return filtered products based on category
    final products = _getDummyProducts();
    // Simple filtering logic for demo
    switch (categoryId) {
      case '1': // Electronics
        return products
            .where(
              (p) =>
                  p.name.contains('هاتف') ||
                  p.name.contains('ساعة') ||
                  p.name.contains('سماعات'),
            )
            .toList();
      case '2': // Clothing
        return products.where((p) => p.name.contains('فستان')).toList();
      case '4': // Sports
        return products.where((p) => p.name.contains('رياضية')).toList();
      default:
        return products.take(2).toList();
    }
  }

  @override
  Future<List<ProductModel>> getSimilarProducts(String productId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final products = _getDummyProducts();

    // Find the current product to get its category
    final currentProduct = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => products.first,
    );

    // Return products from the same category, excluding the current one
    return products
        .where(
          (p) => p.id != productId && p.categoryId == currentProduct.categoryId,
        )
        .take(4)
        .toList();
  }
}
