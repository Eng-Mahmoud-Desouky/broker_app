import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../bloc/product_details_bloc.dart';
import '../widgets/product_shimmer.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_color_selector.dart';
import '../widgets/product_specifications_table.dart';
import '../widgets/similar_products_section.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              di.sl<ProductDetailsBloc>()
                ..add(LoadProductDetails(productId: productId)),
      child: ProductDetailsView(productId: productId),
    );
  }
}

class ProductDetailsView extends StatelessWidget {
  final String productId;

  const ProductDetailsView({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        notificationCount: 3,
        onSupportTap: () async {
          AppRouter.goToSupportList(context);
        },
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
      ),
      body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return const ProductDetailsShimmer();
          } else if (state is ProductDetailsError) {
            return _buildErrorState(context, state.message);
          } else if (state is ProductDetailsLoaded) {
            return _buildProductDetails(context, state.product);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Slider
          ProductImageSlider(
            images: product.images ?? [],
            fallbackImageUrl: product.imageUrl,
            height: 300,
          ),

          // Product Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                // Platform
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.platformName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Price Section
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} ${product.currency}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${product.originalPrice!.toStringAsFixed(2)} ${product.currency}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.grey500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),

                // Discount Badge
                if (product.hasDiscount) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'خصم ${product.discountPercentage!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Rating and Reviews
                if (product.rating != null) ...[
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < product.rating!.floor()
                                ? Icons.star
                                : index < product.rating!
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating!.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (product.reviewCount != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount} تقييم)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Stock Status
                Row(
                  children: [
                    Icon(
                      product.isInStock ? Icons.check_circle : Icons.cancel,
                      color:
                          product.isInStock
                              ? AppColors.success
                              : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.isInStock ? 'متوفر' : 'غير متوفر',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            product.isInStock
                                ? AppColors.success
                                : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'الوصف',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                // Color Selection
                if (product.colors != null && product.colors!.isNotEmpty) ...[
                  ProductColorSelector(
                    colors: product.colors!,
                    onColorSelected: (color) {
                      // Handle color selection
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم اختيار اللون: ${color.label ?? color.colorHex}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],

                // Product Specifications
                ProductSpecificationsTable(
                  specifications: product.specifications,
                ),
                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            product.isInStock
                                ? () {
                                  // TODO: Add to cart functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم إضافة المنتج إلى السلة',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إضافة إلى السلة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // TODO: Add to favorites functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إضافة المنتج إلى المفضلة'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.favorite_border,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Similar Products Section
          const SizedBox(height: 30),
          BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
            builder: (context, state) {
              if (state is ProductDetailsLoaded) {
                return SimilarProductsSection(
                  products: state.similarProducts,
                  isLoading: state.isSimilarProductsLoading,
                  hasError: state.hasSimilarProductsError,
                  errorMessage: state.similarProductsErrorMessage,
                  onProductTap: (product) {
                    // Navigate to the selected product
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProductDetailsPage(productId: product.id),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ProductDetailsBloc>().add(
                LoadProductDetails(productId: productId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
