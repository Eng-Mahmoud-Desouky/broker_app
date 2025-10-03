import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/platform.dart';

class PlatformsGrid extends StatelessWidget {
  final List<Platform> platforms;
  final Function(Platform)? onPlatformTap;

  const PlatformsGrid({super.key, required this.platforms, this.onPlatformTap});

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) {
      return const SizedBox.shrink();
    }

    // Separate platforms by type
    final retailPlatforms =
        platforms.where((p) => p.type == PlatformType.retail).toList();
    final wholesalePlatforms =
        platforms.where((p) => p.type == PlatformType.wholesale).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (retailPlatforms.isNotEmpty) ...[
          _buildSectionHeader('مواقع التجزئة', Icons.shopping_cart_rounded),
          const SizedBox(height: 12),
          _buildPlatformGrid(retailPlatforms),
          const SizedBox(height: 24),
        ],
        if (wholesalePlatforms.isNotEmpty) ...[
          _buildSectionHeader('مواقع الجملة', Icons.business_rounded),
          const SizedBox(height: 12),
          _buildPlatformGrid(wholesalePlatforms),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformGrid(List<Platform> platforms) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Four columns for better circular layout
          crossAxisSpacing: 16, // Spacing between columns
          mainAxisSpacing: 16, // Spacing between rows
          childAspectRatio: 1.0, // Square aspect ratio for circular design
        ),
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          return _buildPlatformCard(platform);
        },
      ),
    );
  }

  Widget _buildPlatformCard(Platform platform) {
    return GestureDetector(
      onTap: () => onPlatformTap?.call(platform),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 3,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      platform.logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.store_rounded,
                          color: AppColors.primary.withValues(alpha: 0.6),
                          size: 28,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              flex: 1,
              child: Text(
                platform.name,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
