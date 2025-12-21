import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../bloc/address_bloc.dart';
import '../widgets/address_card.dart';
import 'add_address_screen.dart';

/// Screen for listing and managing user addresses
class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AddressBloc>()..add(const AddressLoadAll()),
      child: Scaffold(
        appBar: AppBar(title: const Text('عناويني'), centerTitle: true),
        body: BlocConsumer<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AddressDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف العنوان'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AddressLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AddressEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: AppColors.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد عناوين',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أضف عنوان الشحن الخاص بك',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is AddressLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.addresses.length,
                itemBuilder: (context, index) {
                  final address = state.addresses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AddressCard(
                      address: address,
                      onDelete:
                          () => _showDeleteConfirmation(context, address.id),
                      onSetDefault:
                          address.isDefault
                              ? null
                              : () {
                                context.read<AddressBloc>().add(
                                  AddressSetDefault(addressId: address.id),
                                );
                              },
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToAddAddress(context),
          icon: const Icon(Icons.add),
          label: const Text('إضافة عنوان'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  void _navigateToAddAddress(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );

    if (result == true && context.mounted) {
      context.read<AddressBloc>().add(const AddressLoadAll());
    }
  }

  void _showDeleteConfirmation(BuildContext context, String addressId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('حذف العنوان'),
            content: const Text('هل أنت متأكد من حذف هذا العنوان؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<AddressBloc>().add(
                    AddressDelete(addressId: addressId),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }
}
