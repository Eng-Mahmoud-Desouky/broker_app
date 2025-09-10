import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final Function(String)? onSearchSubmitted;
  final Function(String)? onImageSelected;
  final String? hintText;

  const CustomSearchBar({
    super.key,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onImageSelected,
    this.hintText,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null && widget.onImageSelected != null) {
        widget.onImageSelected!(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في اختيار الصورة: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        textDirection: TextDirection.rtl,
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'ابحث عن المنتجات أو أدخل رابط...',
          hintStyle: TextStyle(
            color: AppColors.grey600,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty && widget.onSearchSubmitted != null) {
                  widget.onSearchSubmitted!(_controller.text.trim());
                }
              },
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
              ),
              tooltip: 'بحث',
            ),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _pickImage,
              icon: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
              ),
              tooltip: 'البحث بالصورة',
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
