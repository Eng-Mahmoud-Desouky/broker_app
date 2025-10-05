import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/cart_item.dart';

/// Card widget for displaying a cart item
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                _buildProductImage(),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Platform badge
                      _buildPlatformBadge(),
                      const SizedBox(height: 8),
                      // Price
                      Text(
                        item.price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (item.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.rating!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Remove button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  onPressed: onRemove,
                  tooltip: 'حذف',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Quantity controls and view product button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity controls
                _buildQuantityControls(),
                // View product button
                TextButton.icon(
                  onPressed: () => _openProductUrl(context),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('عرض المنتج'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (!item.hasImages) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.shopping_bag_outlined,
          size: 40,
          color: AppColors.grey500,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: item.primaryImage,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: AppColors.grey200,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          color: AppColors.grey200,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: AppColors.grey500,
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformBadge() {
    Color badgeColor;
    switch (item.platform.toLowerCase()) {
      case 'amazon':
        badgeColor = const Color(0xFFFF9900);
        break;
      case 'shein':
        badgeColor = Colors.black;
        break;
      case 'aliexpress':
        badgeColor = const Color(0xFFE62E04);
        break;
      case 'taobao':
        badgeColor = const Color(0xFFFF6A00);
        break;
      case 'alibaba':
        badgeColor = const Color(0xFFFF6A00);
        break;
      default:
        badgeColor = AppColors.grey600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        item.platformDisplayName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: item.quantity > 1
                ? () => onQuantityChanged(item.quantity - 1)
                : null,
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onQuantityChanged(item.quantity + 1),
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _openProductUrl(BuildContext context) async {
    final uri = Uri.parse(item.productUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح رابط المنتج'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

