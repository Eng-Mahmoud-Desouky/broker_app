import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../address/presentation/pages/add_address_screen.dart';
import '../../../address/presentation/pages/address_list_screen.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../domain/entities/shipping_method.dart';
import '../../../pricing/presentation/cubit/pricing_cubit.dart';
import '../bloc/order_bloc.dart';
import '../widgets/shipping_method_selector.dart';

/// Create order screen where user confirms address and shipping method
class CreateOrderScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CreateOrderScreen({super.key, required this.cartItems});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  ShippingMethod? _selectedShippingMethod;
  String? _selectedAddressId;
  final TextEditingController _promoCodeController = TextEditingController();

  // Promo code validation state
  bool _isValidatingPromo = false;
  bool? _isPromoValid;
  double? _promoDiscountAmount;
  double? _promoFinalPrice;
  double? _promoPercentage;
  String? _promoErrorMessage;

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AddressBloc>()..add(const AddressLoadAll()),
        ),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
        BlocProvider(create: (_) => di.sl<CartBloc>()),
        BlocProvider(
          create: (_) => di.sl<PricingCubit>()..fetchPricingSettings(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء طلب'), centerTitle: true),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderCreated) {
              // Clear cart after successful order creation
              context.read<CartBloc>().add(const CartClear());

              // Show success and navigate back
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.order.discountAmount != null
                        ? 'تم إنشاء الطلب بنجاح: ${state.order.referenceNumber}\n'
                            'السعر النهائي: \$${state.order.totalPrice?.toStringAsFixed(2)}\n'
                            'الخصم: \$${state.order.discountAmount!.toStringAsFixed(2)}'
                        : 'تم إنشاء الطلب بنجاح: ${state.order.referenceNumber}',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 4),
                ),
              );

              // Navigate back with success flag
              Navigator.of(context).pop(true);
            } else if (state is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, orderState) {
            if (orderState is OrderCreating) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cart summary
                  _buildCartSummary(),
                  const SizedBox(height: 24),

                  // Address selection
                  _buildAddressSection(),
                  const SizedBox(height: 24),

                  // Shipping method
                  _buildShippingMethodSection(),
                  const SizedBox(height: 24),

                  // Promo code input
                  _buildPromoCodeSection(),
                  const SizedBox(height: 32),

                  // Confirm button
                  _buildConfirmButton(context),
                  const SizedBox(height: 50), // Extra space at bottom
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    final totalWeight = widget.cartItems.fold<double>(
      0,
      (sum, item) => sum + ((item.weightKg ?? 0) * item.quantity),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص السلة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عدد المنتجات:'),
                Text('${widget.cartItems.length}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الوزن الكلي:'),
                Text('${totalWeight.toStringAsFixed(2)} كجم'),
              ],
            ),
            const Divider(),
            BlocBuilder<PricingCubit, PricingState>(
              builder: (context, state) {
                if (state is PricingLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (state is PricingLoaded) {
                  if (_selectedShippingMethod == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'يرجى اختيار طريقة الشحن لعرض السعر التقريبي',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  final expectedTotal = context
                      .read<PricingCubit>()
                      .calculateExpectedTotal(
                        items: widget.cartItems,
                        settings: state.settings,
                        shippingMethod: _selectedShippingMethod!,
                      );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المبلغ المتوقع:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${expectedTotal.toStringAsFixed(2)} \$',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('عنوان الشحن', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _navigateToAddAddress(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة عنوان'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AddressLoaded) {
              if (state.addresses.isEmpty) {
                return _buildEmptyAddressState();
              }

              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.addresses.length,
                    itemBuilder: (context, index) {
                      final address = state.addresses[index];
                      return Card(
                        elevation: _selectedAddressId == address.id ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                _selectedAddressId == address.id
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                            width: _selectedAddressId == address.id ? 2 : 1,
                          ),
                        ),
                        child: RadioListTile<String>(
                          title: Row(
                            children: [
                              Expanded(child: Text(address.name)),
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'افتراضي',
                                    style: TextStyle(
                                      color: AppColors.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address.fullName),
                              Text(
                                address.formattedAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          value: address.id,
                          groupValue: _selectedAddressId,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() => _selectedAddressId = value);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _navigateToAddressList(),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('إدارة العناوين'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              );
            }

            if (state is AddressEmpty) {
              return _buildEmptyAddressState();
            }

            return const Text('حدث خطأ في تحميل العناوين');
          },
        ),
      ],
    );
  }

  Widget _buildEmptyAddressState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا توجد عناوين',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف عنوان الشحن للمتابعة',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddAddress(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة عنوان جديد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _navigateToAddAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );

    if (result == true && mounted) {
      context.read<AddressBloc>().add(const AddressLoadAll());
    }
  }

  void _navigateToAddressList() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddressListScreen()),
    );

    if (result == true && mounted) {
      context.read<AddressBloc>().add(const AddressLoadAll());
    }
  }

  Widget _buildShippingMethodSection() {
    return ShippingMethodSelector(
      selectedMethod: _selectedShippingMethod,
      onChanged: (method) {
        setState(() => _selectedShippingMethod = method);
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canConfirm() ? () => _confirmOrder(context) : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('تأكيد الطلب'),
      ),
    );
  }

  bool _canConfirm() {
    return _selectedAddressId != null && _selectedShippingMethod != null;
  }

  void _confirmOrder(BuildContext context) {
    if (!_canConfirm()) return;

    context.read<OrderBloc>().add(
      OrderCreate(
        cartItems: widget.cartItems,
        addressId: _selectedAddressId!,
        shippingMethod: _selectedShippingMethod!,
        promoCode:
            _promoCodeController.text.trim().isEmpty
                ? null
                : _promoCodeController.text.trim(),
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return BlocBuilder<PricingCubit, PricingState>(
      builder: (context, pricingState) {
        double? basePrice;

        if (pricingState is PricingLoaded && _selectedShippingMethod != null) {
          basePrice = context.read<PricingCubit>().calculateExpectedTotal(
            items: widget.cartItems,
            settings: pricingState.settings,
            shippingMethod: _selectedShippingMethod!,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كود الخصم (اختياري)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoCodeController,
                    decoration: InputDecoration(
                      hintText: 'أدخل كود الخصم',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.local_offer),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      errorText:
                          _isPromoValid == false ? _promoErrorMessage : null,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) {
                      // Reset validation when user types
                      if (_isPromoValid != null) {
                        setState(() {
                          _isPromoValid = null;
                          _promoDiscountAmount = null;
                          _promoFinalPrice = null;
                          _promoPercentage = null;
                          _promoErrorMessage = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Using IntrinsicHeight on the Row or Container creates logic issues here
                // Simple fix: Override the button style constraints specifically
                ElevatedButton(
                  onPressed:
                      basePrice != null && !_isValidatingPromo
                          ? () => _validatePromoCode(basePrice!)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    // Force height to be reasonable, override theme minSize
                    minimumSize: const Size(0, 48),
                    fixedSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child:
                      _isValidatingPromo
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('تطبيق'),
                ),
              ],
            ),

            // Show price preview when promo is valid
            if (_isPromoValid == true && _promoFinalPrice != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'تم تطبيق الخصم بنجاح!',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السعر الأصلي:',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '\$${basePrice?.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الخصم (${_promoPercentage?.toStringAsFixed(0)}%):',
                          style: const TextStyle(color: AppColors.success),
                        ),
                        Text(
                          '-\$${_promoDiscountAmount?.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السعر النهائي:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${_promoFinalPrice?.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _validatePromoCode(double basePrice) async {
    final promoCode = _promoCodeController.text.trim();

    if (promoCode.isEmpty) {
      setState(() {
        _isPromoValid = false;
        _promoErrorMessage = 'الرجاء إدخال كود الخصم';
      });
      return;
    }

    setState(() {
      _isValidatingPromo = true;
      _promoErrorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.rpc(
        'validate_promo_code',
        params: {'p_promo_code': promoCode, 'p_base_price': basePrice},
      );

      final data =
          response is List && response.isNotEmpty
              ? response[0] as Map<String, dynamic>
              : response as Map<String, dynamic>;

      final isValid = data['is_valid'] as bool;

      setState(() {
        _isValidatingPromo = false;
        _isPromoValid = isValid;

        if (isValid) {
          _promoPercentage = (data['out_percentage'] as num?)?.toDouble();
          _promoDiscountAmount =
              (data['out_discount_amount'] as num?)?.toDouble();
          _promoFinalPrice = (data['out_final_price'] as num?)?.toDouble();
          _promoErrorMessage = null;
        } else {
          _promoErrorMessage = data['out_error_message'] as String?;
          _promoDiscountAmount = null;
          _promoFinalPrice = null;
          _promoPercentage = null;
        }
      });
    } catch (e) {
      debugPrint('❌ Error validating promo code: $e'); // Log the actual error
      setState(() {
        _isValidatingPromo = false;
        _isPromoValid = false;
        _promoErrorMessage = 'حدث خطأ أثناء التحقق من الكود';
      });
    }
  }
}
