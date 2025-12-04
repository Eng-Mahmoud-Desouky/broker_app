import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../bloc/product_list_bloc.dart';
import '../widgets/product_shimmer.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ProductListBloc>()..add(const LoadProducts()),
      child: const ProductListView(),
    );
  }
}

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

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
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state is ProductListLoading) {
            return const ProductListShimmer();
          } else if (state is ProductListError) {
            return _buildErrorState(context, state.message);
          } else if (state is ProductListEmpty) {
            return _buildEmptyState();
          } else if (state is ProductListLoaded ||
              state is ProductListRefreshing) {
            final products =
                state is ProductListLoaded
                    ? state.products
                    : (state as ProductListRefreshing).products;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductListBloc>().add(const RefreshProducts());
              },
              color: AppColors.primary,
              child: _buildProductGrid(context, products),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            context.push('/product-details/${product.id}');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: AppColors.grey100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: AppColors.grey100,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.grey400,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                ),

                // Product Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Platform
                        Text(
                          product.platformName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                        ),
                        const Spacer(),

                        // Price and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.price.toStringAsFixed(2)} ${product.currency}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (product.originalPrice != null)
                                  Text(
                                    '${product.originalPrice!.toStringAsFixed(2)} ${product.currency}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),

                            // Rating
                            if (product.rating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    product.rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: const TextStyle(
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
              context.read<ProductListBloc>().add(const LoadProducts());
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey400),
          SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'لم يتم العثور على أي منتجات',
            style: TextStyle(fontSize: 14, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
