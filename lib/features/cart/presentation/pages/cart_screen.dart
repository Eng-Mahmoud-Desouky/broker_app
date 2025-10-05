import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_empty_widget.dart';
import '../widgets/cart_summary_widget.dart';

/// Cart screen showing all cart items
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    _cartBloc = di.sl<CartBloc>();
    _cartBloc.add(const CartLoadItems());
  }

  @override
  void dispose() {
    _cartBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cartBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('السلة'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          actions: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoaded && state.items.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showClearCartDialog(context),
                    tooltip: 'مسح السلة',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is CartItemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة المنتج للسلة'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is CartOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is CartEmpty) {
              return const CartEmptyWidget();
            }

            if (state is CartLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  _cartBloc.add(const CartRefresh());
                  await Future.delayed(const Duration(seconds: 1));
                },
                color: AppColors.primary,
                child: Column(
                  children: [
                    // Cart items list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return CartItemCard(
                            item: item,
                            onQuantityChanged: (quantity) {
                              _cartBloc.add(
                                CartUpdateQuantity(
                                  itemId: item.id,
                                  quantity: quantity,
                                ),
                              );
                            },
                            onRemove: () {
                              _cartBloc.add(CartRemoveItem(itemId: item.id));
                            },
                          );
                        },
                      ),
                    ),
                    // Cart summary
                    CartSummaryWidget(
                      totalItems: state.totalItems,
                      totalPrice: state.totalPrice,
                    ),
                  ],
                ),
              );
            }

            if (state is CartError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _cartBloc.add(const CartLoadItems());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل أنت متأكد من مسح جميع المنتجات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _cartBloc.add(const CartClear());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }
}

