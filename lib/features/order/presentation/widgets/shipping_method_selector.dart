import 'package:flutter/material.dart';

import '../../domain/entities/shipping_method.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget for selecting shipping method (Sea or Air)
class ShippingMethodSelector extends StatelessWidget {
  final ShippingMethod? selectedMethod;
  final ValueChanged<ShippingMethod>? onChanged;

  const ShippingMethodSelector({
    super.key,
    this.selectedMethod,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الشحن',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          context: context,
          method: ShippingMethod.sea,
          icon: '⛴️',
          label: 'شحن بحري',
          description: 'أقل تكلفة، وقت أطول',
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          context: context,
          method: ShippingMethod.air,
          icon: '✈️',
          label: 'شحن جوي',
          description: 'أسرع، تكلفة أعلى',
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required BuildContext context,
    required ShippingMethod method,
    required String icon,
    required String label,
    required String description,
  }) {
    final isSelected = selectedMethod == method;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(method) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            // Radio button
            Radio<ShippingMethod>(
              value: method,
              groupValue: selectedMethod,
              onChanged:
                  onChanged != null ? (value) => onChanged!(method) : null,
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            // Icon
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            // Label and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
