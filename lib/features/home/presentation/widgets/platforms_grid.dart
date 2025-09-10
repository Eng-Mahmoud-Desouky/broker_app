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
    final isRetail = platform.type == PlatformType.retail;
    final primaryColor = isRetail ? AppColors.primary : AppColors.secondary;

    return GestureDetector(
      onTap: () => onPlatformTap?.call(platform),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, primaryColor.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 8,
              offset: const Offset(-2, -2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Platform Logo with modern container
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    platform.logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          color: primaryColor,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Platform Name with modern typography
              Text(
                platform.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Platform Description with better styling
              Text(
                platform.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Modern indicator dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
