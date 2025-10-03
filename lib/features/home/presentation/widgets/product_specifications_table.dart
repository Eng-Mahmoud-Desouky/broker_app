import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProductSpecificationsTable extends StatelessWidget {
  final Map<String, dynamic>? specifications;

  const ProductSpecificationsTable({
    super.key,
    this.specifications,
  });

  @override
  Widget build(BuildContext context) {
    if (specifications == null || specifications!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'المواصفات التقنية',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Specifications table
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: _buildSpecificationRows(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSpecificationRows() {
    final entries = specifications!.entries.toList();
    final List<Widget> rows = [];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;

      rows.add(_buildSpecificationRow(
        key: entry.key,
        value: _formatValue(entry.value),
        isLast: isLast,
      ));
    }

    return rows;
  }

  Widget _buildSpecificationRow({
    required String key,
    required String value,
    required bool isLast,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Specification key
            Expanded(
              flex: 2,
              child: Text(
                key,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),

            // Separator
            Container(
              width: 1,
              height: 20,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // Specification value
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return 'غير محدد';
    }

    if (value is String) {
      return value;
    }

    if (value is num) {
      return value.toString();
    }

    if (value is bool) {
      return value ? 'نعم' : 'لا';
    }

    if (value is List) {
      return value.join(', ');
    }

    if (value is Map) {
      // For nested objects, create a simple string representation
      return value.entries
          .map((e) => '${e.key}: ${_formatValue(e.value)}')
          .join(', ');
    }

    return value.toString();
  }
}
