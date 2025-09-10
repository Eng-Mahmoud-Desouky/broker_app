import '../models/offer_model.dart';
import '../models/platform_model.dart';
import '../models/product_model.dart';
import '../../domain/entities/platform.dart';

abstract class HomeLocalDataSource {
  Future<List<OfferModel>> getFeaturedOffers();
  Future<List<PlatformModel>> getPlatforms();
  Future<List<PlatformModel>> getPlatformsByType(String type);
  Future<List<ProductModel>> getSuggestedProducts();
  Future<List<ProductModel>> searchProducts(String query);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  // Dummy data for offers
  final List<OfferModel> _dummyOffers = [
    OfferModel(
      id: '1',
      title: 'خصم 50% على جميع المنتجات',
      description: 'عرض محدود لفترة قصيرة',
      imageUrl:
          'https://via.placeholder.com/400x200/213c86/ffffff?text=Offer+1',
      discountPercentage: '50%',
      validUntil: DateTime.now().add(const Duration(days: 7)),
      actionUrl: '/offers/1',
    ),
    OfferModel(
      id: '2',
      title: 'شحن مجاني للطلبات فوق 100 دولار',
      description: 'استمتع بالشحن المجاني',
      imageUrl:
          'https://via.placeholder.com/400x200/8e2600/ffffff?text=Offer+2',
      discountPercentage: null,
      validUntil: DateTime.now().add(const Duration(days: 14)),
      actionUrl: '/offers/2',
    ),
    OfferModel(
      id: '3',
      title: 'منتجات جديدة من أمازون',
      description: 'اكتشف أحدث المنتجات',
      imageUrl:
          'https://via.placeholder.com/400x200/213c86/ffffff?text=Offer+3',
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

  @override
  Future<List<OfferModel>> getFeaturedOffers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyOffers;
  }

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
        id: '1',
        name: 'هاتف ذكي أندرويد',
        description: 'هاتف ذكي بمواصفات عالية',
        imageUrl:
            'https://via.placeholder.com/200x200/213c86/ffffff?text=Phone',
        price: 299.99,
        currency: 'USD',
        originalPrice: 399.99,
        rating: 4.5,
        reviewCount: 1250,
        platformId: 'amazon',
        platformName: 'Amazon',
      ),
      ProductModel(
        id: '2',
        name: 'فستان صيفي أنيق',
        description: 'فستان مناسب للصيف',
        imageUrl:
            'https://via.placeholder.com/200x200/8e2600/ffffff?text=Dress',
        price: 29.99,
        currency: 'USD',
        originalPrice: 49.99,
        rating: 4.2,
        reviewCount: 890,
        platformId: 'shein',
        platformName: 'SHEIN',
      ),
      ProductModel(
        id: '3',
        name: 'ساعة ذكية رياضية',
        description: 'ساعة ذكية لتتبع اللياقة',
        imageUrl:
            'https://via.placeholder.com/200x200/213c86/ffffff?text=Watch',
        price: 149.99,
        currency: 'USD',
        rating: 4.7,
        reviewCount: 2100,
        platformId: 'aliexpress',
        platformName: 'AliExpress',
      ),
      ProductModel(
        id: '4',
        name: 'حقيبة يد نسائية',
        description: 'حقيبة أنيقة للاستخدام اليومي',
        imageUrl: 'https://via.placeholder.com/200x200/8e2600/ffffff?text=Bag',
        price: 79.99,
        currency: 'USD',
        originalPrice: 120.00,
        rating: 4.3,
        reviewCount: 567,
        platformId: 'taobao',
        platformName: 'Taobao',
      ),
      ProductModel(
        id: '5',
        name: 'سماعات لاسلكية',
        description: 'سماعات بلوتوث عالية الجودة',
        imageUrl:
            'https://via.placeholder.com/200x200/213c86/ffffff?text=Headphones',
        price: 89.99,
        currency: 'USD',
        rating: 4.6,
        reviewCount: 1890,
        platformId: 'alibaba',
        platformName: 'Alibaba',
      ),
    ];
  }
}
