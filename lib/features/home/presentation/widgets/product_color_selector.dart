import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';

class ProductColorSelector extends StatefulWidget {
  final List<ProductColor> colors;
  final ProductColor? selectedColor;
  final ValueChanged<ProductColor>? onColorSelected;

  const ProductColorSelector({
    super.key,
    required this.colors,
    this.selectedColor,
    this.onColorSelected,
  });

  @override
  State<ProductColorSelector> createState() => _ProductColorSelectorState();
}

class _ProductColorSelectorState extends State<ProductColorSelector> {
  ProductColor? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor ?? (widget.colors.isNotEmpty ? widget.colors.first : null);
  }

  @override
  void didUpdateWidget(ProductColorSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor) {
      _selectedColor = widget.selectedColor;
    }
  }

  void _selectColor(ProductColor color) {
    setState(() {
      _selectedColor = color;
    });
    widget.onColorSelected?.call(color);
  }

  Color _parseHexColor(String hexColor) {
    try {
      // Remove # if present
      String cleanHex = hexColor.replaceAll('#', '');
      
      // Add alpha if not present
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      // Return a default color if parsing fails
      return AppColors.grey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.colors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'الألوان المتاحة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Selected color label
        if (_selectedColor?.label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _selectedColor!.label!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        
        if (_selectedColor?.label != null) const SizedBox(height: 12),

        // Color options
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.colors.map((color) => _buildColorOption(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(ProductColor color) {
    final isSelected = _selectedColor?.id == color.id;
    final colorValue = _parseHexColor(color.colorHex);

    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorValue,
            border: Border.all(
              color: _needsBorder(colorValue) ? AppColors.border : Colors.transparent,
              width: 1,
            ),
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  color: _getContrastColor(colorValue),
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }

  // Helper method to determine if a color needs a border (for very light colors)
  bool _needsBorder(Color color) {
    // Calculate luminance to determine if the color is very light
    final luminance = color.computeLuminance();
    return luminance > 0.9;
  }

  // Helper method to get contrasting color for the check icon
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
