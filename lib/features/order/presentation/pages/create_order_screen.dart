import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/shipping_method.dart';
import '../bloc/order_bloc.dart';

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
        Text('عنوان الشحن', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AddressLoaded) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.addresses.length,
                itemBuilder: (context, index) {
                  final address = state.addresses[index];
                  return RadioListTile<String>(
                    title: Text(address.name),
                    subtitle: Text(address.formattedAddress),
                    value: address.id,
                    groupValue: _selectedAddressId,
                    onChanged: (value) {
                      setState(() => _selectedAddressId = value);
                    },
                  );
                },
              );
            }

            return const Text('لا توجد عناوين');
          },
        ),
      ],
    );
  }

  Widget _buildShippingMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('طريقة الشحن', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        RadioListTile<ShippingMethod>(
          title: const Row(children: [Text('⛴️ '), Text('شحن بحري')]),
          value: ShippingMethod.sea,
          groupValue: _selectedShippingMethod,
          onChanged: (value) {
            setState(() => _selectedShippingMethod = value);
          },
        ),
        RadioListTile<ShippingMethod>(
          title: const Row(children: [Text('✈️ '), Text('شحن جوي')]),
          value: ShippingMethod.air,
          groupValue: _selectedShippingMethod,
          onChanged: (value) {
            setState(() => _selectedShippingMethod = value);
          },
        ),
      ],
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
