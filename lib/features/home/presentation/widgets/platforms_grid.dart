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
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8, // Increased height to prevent overflow
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
    final cleanedName = platform.name.trim().toLowerCase();

    // Convert hex string to Color
    Color brandColor = Colors.white;
    if (platform.brandColor != null) {
      try {
        final hex = platform.brandColor!.replaceAll('#', '');
        brandColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        brandColor = Colors.white;
      }
    } else {
      // Fallback colors for known platforms
      switch (cleanedName) {
        case 'aliexpress':
          brandColor = const Color(0xFFE42D02);
          break;
        case 'alibaba':
          brandColor = const Color(0xFFFF6600);
          break;
        case 'shein':
          brandColor = Colors.black;
          break;
        case 'taobao':
          brandColor = const Color(0xFFFF5000);
          break;
        case 'amazon':
          brandColor = const Color(0xFFFDFFFF);
          break;
      }
    }

    // Use local assets for these specific platforms
    String? localAsset;
    final knownPlatforms = [
      'aliexpress',
      'alibaba',
      'shein',
      'taobao',
      'amazon',
    ];
    if (knownPlatforms.contains(cleanedName)) {
      localAsset = 'assets/images/platforms/$cleanedName.png';
    }

    return GestureDetector(
      onTap: () => onPlatformTap?.call(platform),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, // Slightly reduced to ensure it fits comfortably
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandColor,
              boxShadow: [
                BoxShadow(
                  color: brandColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child:
                    localAsset != null
                        ? Image.asset(
                          localAsset,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => _buildFallbackImage(platform),
                        )
                        : _buildFallbackImage(platform),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            platform.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage(Platform platform) {
    return Image.asset(
      platform.logoUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.store_rounded, color: Colors.white, size: 24);
      },
    );
  }
}
