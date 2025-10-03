import 'package:equatable/equatable.dart';

/// Represents a platform with its associated URL for WebView browsing
class PlatformUrl extends Equatable {
  final String platformId;
  final String platformName;
  final String url;
  final String displayName;
  final bool requiresUserAgent;
  final Map<String, String>? headers;

  const PlatformUrl({
    required this.platformId,
    required this.platformName,
    required this.url,
    required this.displayName,
    this.requiresUserAgent = false,
    this.headers,
  });

  @override
  List<Object?> get props => [
        platformId,
        platformName,
        url,
        displayName,
        requiresUserAgent,
        headers,
      ];
}

/// Predefined platform URLs for major shopping platforms
class PlatformUrls {
  static const Map<String, PlatformUrl> platforms = {
    'amazon': PlatformUrl(
      platformId: 'amazon',
      platformName: 'Amazon',
      url: 'https://www.amazon.com',
      displayName: 'Amazon',
      requiresUserAgent: true,
    ),
    'alibaba': PlatformUrl(
      platformId: 'alibaba',
      platformName: 'Alibaba',
      url: 'https://www.alibaba.com',
      displayName: 'Alibaba',
      requiresUserAgent: true,
    ),
    'shein': PlatformUrl(
      platformId: 'shein',
      platformName: 'SHEIN',
      url: 'https://www.shein.com',
      displayName: 'SHEIN',
      requiresUserAgent: true,
    ),
    'taobao': PlatformUrl(
      platformId: 'taobao',
      platformName: 'Taobao',
      url: 'https://world.taobao.com',
      displayName: 'Taobao',
      requiresUserAgent: true,
    ),
    'aliexpress': PlatformUrl(
      platformId: 'aliexpress',
      platformName: 'AliExpress',
      url: 'https://www.aliexpress.com',
      displayName: 'AliExpress',
      requiresUserAgent: true,
    ),
  };

  static PlatformUrl? getPlatformUrl(String platformId) {
    return platforms[platformId];
  }

  static List<PlatformUrl> getAllPlatforms() {
    return platforms.values.toList();
  }
}
