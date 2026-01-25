import 'package:broker_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/bloc/notifications_cubit.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../webview/domain/entities/platform_url.dart';
import '../bloc/home_bloc.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/offers_banner_slider.dart';
import '../widgets/platforms_grid.dart';
import '../widgets/suggested_products_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load initial data when page loads
    context.read<HomeBloc>().add(const HomeLoadInitialData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            int count = 0;
            if (state is NotificationsLoaded) {
              count = state.unreadCount;
            }
            return CustomAppBar(
              notificationCount: count,
              onSupportTap: () async {
                AppRouter.goToSupportList(context);
              },
              onNotificationTap: () {
                context.push('/notifications');
              },
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(const HomeRefreshData());
        },
        color: AppColors.primary,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return _buildLoadingState();
            } else if (state is HomeError) {
              return _buildErrorState(state.message);
            } else if (state is HomeSearching) {
              return _buildSearchingState();
            } else if (state is HomeSearchResults) {
              return _buildSearchResultsState(state);
            } else if (state is HomeLoaded) {
              return _buildLoadedState(state);
            }

            return _buildInitialState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(fontSize: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<HomeBloc>().add(const HomeLoadInitialData());
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

  Widget _buildSearchingState() {
    return Column(
      children: [
        CustomSearchBar(
          onSearchChanged: (query) {
            context.read<HomeBloc>().add(HomeSearchProducts(query: query));
          },
          onSearchSubmitted: (query) {
            context.read<HomeBloc>().add(HomeSearchProducts(query: query));
          },
          onImageSelected: (imagePath) {
            context.read<HomeBloc>().add(
              HomeSearchProductsByImage(imagePath: imagePath),
            );
          },
        ),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'جاري البحث...',
                  style: TextStyle(fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultsState(HomeSearchResults state) {
    return Column(
      children: [
        CustomSearchBar(
          onSearchChanged: (query) {
            context.read<HomeBloc>().add(HomeSearchProducts(query: query));
          },
          onSearchSubmitted: (query) {
            context.read<HomeBloc>().add(HomeSearchProducts(query: query));
          },
          onImageSelected: (imagePath) {
            context.read<HomeBloc>().add(
              HomeSearchProductsByImage(imagePath: imagePath),
            );
          },
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'نتائج البحث عن: "${state.query}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(
                          const HomeLoadInitialData(),
                        );
                      },
                      child: const Text('العودة للرئيسية'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    state.results.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.grey400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لم يتم العثور على نتائج',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: state.results.length,
                          itemBuilder: (context, index) {
                            final product = state.results[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to product details
                                context.push('/product-details/${product.id}');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          product.imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: AppColors.grey200,
                                              child: const Icon(
                                                Icons
                                                    .image_not_supported_rounded,
                                                color: AppColors.grey600,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.secondary,
                                              ),
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
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedState(HomeLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          CustomSearchBar(
            readOnly: true,
            onTap: () {
              AppRouter.goToSearch(context);
            },
            hintText: 'Search across shopping platforms...',
          ),

          // Offers Banner
          if (state.offers.isNotEmpty) ...[
            OffersBannerSlider(
              offers: state.offers,
              onOfferTap: (offer) {
                context.read<HomeBloc>().add(HomeOfferTapped(offer: offer));
                // TODO: Navigate to offer details or offers page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم اختيار العرض: ${offer.title}'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // View All Offers Button
          if (state.offers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to offers page
                    context.push('/offers');
                  },
                  icon: const Icon(Icons.local_offer_rounded),
                  label: const Text('عرض جميع العروض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Platforms Grid
          if (state.platforms.isNotEmpty) ...[
            PlatformsGrid(
              platforms: state.platforms,
              onPlatformTap: (platform) {
                context.read<HomeBloc>().add(
                  HomePlatformSelected(platform: platform),
                );

                // Get platform URL and navigate to WebView
                final platformUrl = PlatformUrls.getPlatformUrl(platform.id);
                if (platformUrl != null) {
                  final encodedUrl = Uri.encodeComponent(platformUrl.url);
                  final encodedTitle = Uri.encodeComponent(
                    platformUrl.displayName,
                  );
                  context.push('/webview?url=$encodedUrl&title=$encodedTitle');
                } else {
                  // Fallback to platform products page if URL not found
                  context.push('/platform/${platform.id}');
                }
              },
            ),
            const SizedBox(height: 32),
          ],

          // Suggested Products
          if (state.suggestedProducts.isNotEmpty) ...[
            SuggestedProductsList(
              products: state.suggestedProducts,
              onProductTap: (product) {
                // Navigate to product details
                context.push('/product-details/${product.id}');
              },
            ),
            const SizedBox(height: 16),

            // View All Products Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/products');
                  },
                  icon: const Icon(Icons.inventory_2_rounded),
                  label: const Text('عرض جميع المنتجات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text(
        'مرحباً بك في زد إكسبريس',
        style: TextStyle(fontSize: 18, color: AppColors.primary),
      ),
    );
  }
}
