import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/platform.dart';

class PlatformsGrid extends StatelessWidget {
  final List<Platform> platforms;
  final Function(Platform)? onPlatformTap;

  const PlatformsGrid({
    super.key,
    required this.platforms,
    this.onPlatformTap,
  });

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) {
      return const SizedBox.shrink();
    }

    // Separate platforms by type
    final retailPlatforms = platforms.where((p) => p.type == PlatformType.retail).toList();
    final wholesalePlatforms = platforms.where((p) => p.type == PlatformType.wholesale).toList();

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
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
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
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Platform Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: platform.type == PlatformType.retail 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  platform.logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.store_rounded,
                      color: platform.type == PlatformType.retail 
                          ? AppColors.primary
                          : AppColors.secondary,
                      size: 32,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Platform Name
            Text(
              platform.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Platform Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                platform.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
