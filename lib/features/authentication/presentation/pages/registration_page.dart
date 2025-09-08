import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/registration_bloc.dart';
import '../widgets/auth_header.dart';
import '../widgets/loading_overlay.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              sl<RegistrationBloc>()
                ..add(const RegistrationGovernoatesLoaded()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state.formStatus == RegistrationFormStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إكمال التسجيل بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
              AppRouter.goToHome(context);
            } else if (state.formStatus == RegistrationFormStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'حدث خطأ أثناء التسجيل'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state.formStatus == RegistrationFormStatus.submitting,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthHeader(
                          title: 'إكمال التسجيل',
                          subtitle: 'يرجى إدخال بياناتك الشخصية لإكمال التسجيل',
                        ),
                        const SizedBox(height: 40),

                        // Full Name Field
                        _buildNameField(context, state),
                        const SizedBox(height: 24),

                        // Governorate Dropdown
                        _buildGovernorateDropdown(context, state),
                        const SizedBox(height: 24),

                        // District Dropdown
                        _buildDistrictDropdown(context, state),
                        const SizedBox(height: 40),

                        // Submit Button
                        _buildSubmitButton(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context, RegistrationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاسم الكامل',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أدخل اسمك الكامل',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.bodyMedium,
          onChanged: (value) {
            context.read<RegistrationBloc>().add(
              RegistrationNameChanged(value),
            );
          },
          validator: (value) => state.nameError,
        ),
        if (state.nameError != null) ...[
          const SizedBox(height: 4),
          Text(
            state.nameError!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildGovernorateDropdown(
    BuildContext context,
    RegistrationState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المحافظة',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.governorate.isEmpty ? null : state.governorate,
          decoration: InputDecoration(
            hintText: 'اختر المحافظة',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.bodyMedium,
          isExpanded: true,
          items:
              state.governorates.map((governorate) {
                return DropdownMenuItem<String>(
                  value: governorate.governorate,
                  child: Text(
                    governorate.governorate,
                    textDirection: TextDirection.rtl,
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<RegistrationBloc>().add(
                RegistrationGovernorateSelected(value),
              );
            }
          },
          validator: (value) => state.governorateError,
        ),
        if (state.governorateError != null) ...[
          const SizedBox(height: 4),
          Text(
            state.governorateError!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildDistrictDropdown(BuildContext context, RegistrationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'القضاء',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.district.isEmpty ? null : state.district,
          decoration: InputDecoration(
            hintText: 'اختر القضاء',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.bodyMedium,
          isExpanded: true,
          items:
              state.availableDistricts.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district, textDirection: TextDirection.rtl),
                );
              }).toList(),
          onChanged:
              state.governorate.isEmpty
                  ? null
                  : (value) {
                    if (value != null) {
                      context.read<RegistrationBloc>().add(
                        RegistrationDistrictSelected(value),
                      );
                    }
                  },
          validator: (value) => state.districtError,
        ),
        if (state.districtError != null) ...[
          const SizedBox(height: 4),
          Text(
            state.districtError!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, RegistrationState state) {
    final isEnabled = state.formStatus == RegistrationFormStatus.valid;

    return ElevatedButton(
      onPressed:
          isEnabled
              ? () {
                context.read<RegistrationBloc>().add(
                  const RegistrationSubmitted(),
                );
              }
              : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.onSurfaceVariant.withOpacity(0.12),
        disabledForegroundColor: AppColors.onSurfaceVariant.withOpacity(0.38),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(
        'إكمال التسجيل',
        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
