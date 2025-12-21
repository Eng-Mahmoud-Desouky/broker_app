import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../address/presentation/pages/add_address_screen.dart';
import '../../../address/presentation/pages/address_list_screen.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/shipping_method.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AddressBloc>()..add(const AddressLoadAll()),
        ),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء طلب'), centerTitle: true),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderCreated) {
              // Show success and navigate back
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إنشاء الطلب: ${state.order.referenceNumber}',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
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
                  const SizedBox(height: 32),

                  // Confirm button
                  _buildConfirmButton(context),
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
      ),
    );
  }
}
