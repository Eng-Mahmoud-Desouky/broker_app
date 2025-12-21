import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_address.dart';
import '../bloc/address_bloc.dart';

/// Screen for adding a new address
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AddressBloc>(),
      child: Builder(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('إضافة عنوان جديد'),
                centerTitle: true,
              ),
              body: BlocConsumer<AddressBloc, AddressState>(
                listener: (context, state) {
                  if (state is AddressAdded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة العنوان بنجاح'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context, true);
                  } else if (state is AddressError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AddressLoading;

                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم العنوان',
                              hintText: 'مثال: المنزل، العمل',
                              prefixIcon: Icon(Icons.label),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال اسم العنوان';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Full Name
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'الاسم الكامل',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال الاسم الكامل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الهاتف',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Country
                          TextFormField(
                            controller: _countryController,
                            decoration: const InputDecoration(
                              labelText: 'الدولة',
                              prefixIcon: Icon(Icons.flag),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال الدولة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // City
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'المدينة',
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال المدينة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Street
                          TextFormField(
                            controller: _streetController,
                            decoration: const InputDecoration(
                              labelText: 'الشارع',
                              prefixIcon: Icon(Icons.signpost),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال اسم الشارع';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Building (optional)
                          TextFormField(
                            controller: _buildingController,
                            decoration: const InputDecoration(
                              labelText: 'رقم البناية (اختياري)',
                              prefixIcon: Icon(Icons.apartment),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Apartment (optional)
                          TextFormField(
                            controller: _apartmentController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الشقة (اختياري)',
                              prefixIcon: Icon(Icons.meeting_room),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Postal Code (optional)
                          TextFormField(
                            controller: _postalCodeController,
                            decoration: const InputDecoration(
                              labelText: 'الرمز البريدي (اختياري)',
                              prefixIcon: Icon(Icons.mail),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Is Default
                          SwitchListTile(
                            title: const Text('جعله العنوان الافتراضي'),
                            value: _isDefault,
                            onChanged: (value) {
                              setState(() => _isDefault = value);
                            },
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () => _saveAddress(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.onPrimary,
                                              ),
                                        ),
                                      )
                                      : const Text('حفظ العنوان'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }

  void _saveAddress(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get user ID from Supabase (will be handled in repository)
    final address = UserAddress(
      id: '', // Will be generated by Supabase
      userId: '', // Will be set by repository
      name: _nameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      streetAddress: _streetController.text.trim(),
      buildingNumber:
          _buildingController.text.trim().isEmpty
              ? null
              : _buildingController.text.trim(),
      apartmentNumber:
          _apartmentController.text.trim().isEmpty
              ? null
              : _apartmentController.text.trim(),
      postalCode:
          _postalCodeController.text.trim().isEmpty
              ? null
              : _postalCodeController.text.trim(),
      isDefault: _isDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<AddressBloc>().add(AddressAdd(address: address));
  }
}
