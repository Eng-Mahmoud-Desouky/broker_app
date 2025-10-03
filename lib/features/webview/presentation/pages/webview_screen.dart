import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../bloc/webview_bloc.dart';
import '../bloc/webview_event.dart';
import '../bloc/webview_state.dart';
import '../widgets/webview_app_bar.dart';
import '../widgets/webview_error_widget.dart';
import '../widgets/webview_progress_indicator.dart';

/// Reusable WebView screen for browsing shopping platforms
class WebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String title;

  const WebViewScreen({
    super.key,
    required this.initialUrl,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  late WebViewBloc _webViewBloc;

  // Track navigation to prevent infinite loops
  final Set<String> _visitedUrls = <String>{};
  String? _lastLoadedUrl;
  int _navigationCount = 0;

  @override
  void initState() {
    super.initState();
    _webViewBloc = di.sl<WebViewBloc>();
    // Load the initial URL
    _webViewBloc.add(WebViewLoadUrl(url: widget.initialUrl));
  }

  @override
  void dispose() {
    _webViewBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _webViewBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: WebViewAppBar(
          title: widget.title,
          onClose: () => Navigator.of(context).pop(),
        ),
        body: Column(
          children: [
            // Progress indicator
            const WebViewProgressIndicator(),
            // WebView content
            Expanded(
              child: BlocConsumer<WebViewBloc, WebViewBlocState>(
                listener: (context, state) {
                  if (state is WebViewNavigating) {
                    if (state.isGoingBack) {
                      _webViewController?.goBack();
                    } else {
                      _webViewController?.goForward();
                    }
                  } else if (state is WebViewClearingData) {
                    _clearWebViewData();
                  }
                },
                builder: (context, state) {
                  if (state is WebViewErrorState) {
                    return WebViewErrorWidget(
                      message: state.message,
                      url: state.url,
                    );
                  }

                  return _buildWebView();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
      initialSettings: InAppWebViewSettings(
        // Enhanced JavaScript settings for modern e-commerce sites
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        domStorageEnabled: true,
        databaseEnabled: true,

        // Enhanced User-Agent for better compatibility
        userAgent: _getEnhancedUserAgent(),

        // Security settings - Allow mixed content for shopping sites
        mixedContentMode: MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccessFromFileURLs: false,
        allowUniversalAccessFromFileURLs: false,

        // Enhanced Android-specific settings
        safeBrowsingEnabled:
            false, // Disable to avoid blocking legitimate sites
        // Enhanced viewport and rendering settings
        useWideViewPort: true,
        loadWithOverviewMode: true,
        supportZoom: true,
        builtInZoomControls: false,
        displayZoomControls: false,

        // Enhanced cache and performance settings
        cacheEnabled: true,
        clearCache: false,

        // Enhanced cookie settings - Critical for Chinese e-commerce sites
        thirdPartyCookiesEnabled: true,

        // Network settings
        blockNetworkImage: false,
        blockNetworkLoads: false,

        // Enhanced performance settings
        useOnLoadResource: true,
        useOnDownloadStart: false,

        // Platform specific settings
        allowsBackForwardNavigationGestures: true,
        allowsLinkPreview: false,

        // Enhanced context menu settings
        disableContextMenu: false,
        disableLongPressContextMenuOnLinks: false,

        // Enhanced SPA and Multiple Windows Support
        supportMultipleWindows: true,

        // Enhanced Android WebView settings
        hardwareAcceleration: true,
        regexToCancelSubFramesLoading: null,

        // Enhanced storage settings
        allowFileAccess: true,
        allowContentAccess: true,

        // Enhanced rendering settings
        forceDark: ForceDark.OFF,

        // Enhanced text settings
        textZoom: 100,

        // Enhanced scroll settings
        verticalScrollBarEnabled: true,
        horizontalScrollBarEnabled: true,

        // Geolocation settings
        geolocationEnabled: false,

        // Enhanced algorithm settings
        layoutAlgorithm: LayoutAlgorithm.NORMAL,

        // Enhanced minimum font size
        minimumFontSize: 8,

        // Enhanced default font size
        defaultFontSize: 16,

        // Enhanced cursive font family
        cursiveFontFamily: "cursive",

        // Enhanced fantasy font family
        fantasyFontFamily: "fantasy",

        // Enhanced fixed font family
        fixedFontFamily: "monospace",

        // Enhanced sans serif font family
        sansSerifFontFamily: "sans-serif",

        // Enhanced serif font family
        serifFontFamily: "serif",

        // Enhanced standard font family
        standardFontFamily: "sans-serif",

        // Enhanced default text encoding
        defaultTextEncodingName: "utf-8",

        // Enhanced settings for better compatibility
        disableDefaultErrorPage: false,
      ),
      onWebViewCreated: (controller) async {
        _webViewController = controller;

        // Configure enhanced cookie manager for better session handling
        await _configureEnhancedCookies();

        // Inject JavaScript for better compatibility
        await _injectCompatibilityScripts(controller);

        if (kDebugMode) {
          debugPrint(
            '🌐 WebView created with User-Agent: ${_getEnhancedUserAgent()}',
          );
        }
      },
      onLoadStart: (controller, url) {
        if (url != null) {
          final urlString = url.toString();
          _navigationCount++;

          // Check for infinite loop prevention
          if (_lastLoadedUrl == urlString && _navigationCount > 5) {
            if (kDebugMode) {
              debugPrint('🚫 Potential infinite loop detected for: $urlString');
            }
            return;
          }

          _lastLoadedUrl = urlString;
          _visitedUrls.add(urlString);

          if (kDebugMode) {
            debugPrint(
              '🔄 WebView started loading (#$_navigationCount): $urlString',
            );
            debugPrint('🌐 User-Agent: ${_getEnhancedUserAgent()}');
          }
          _webViewBloc.add(WebViewStartedLoading(url: urlString));
        }
      },
      onLoadStop: (controller, url) async {
        if (url != null) {
          if (kDebugMode) {
            debugPrint('✅ WebView finished loading: ${url.toString()}');
          }
          _webViewBloc.add(WebViewFinishedLoading(url: url.toString()));

          // Inject additional compatibility scripts after page load
          await _injectPostLoadScripts(controller, url.toString());

          // Update navigation state
          final canGoBack = await controller.canGoBack();
          final canGoForward = await controller.canGoForward();
          _webViewBloc.add(
            WebViewNavigationStateChanged(
              canGoBack: canGoBack,
              canGoForward: canGoForward,
            ),
          );

          // Update title
          final title = await controller.getTitle();
          if (title != null && title.isNotEmpty) {
            _webViewBloc.add(WebViewTitleChanged(title: title));
          }
        }
      },
      onProgressChanged: (controller, progress) {
        _webViewBloc.add(WebViewProgressChanged(progress: progress / 100.0));
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        if (url != null) {
          _webViewBloc.add(WebViewUrlChanged(url: url.toString()));
        }
      },
      onReceivedError: (controller, request, error) {
        // Only handle main frame errors, ignore sub-frame/resource errors
        if (request.isForMainFrame == true) {
          if (kDebugMode) {
            debugPrint(
              '❌ Main frame error: ${error.description} for URL: ${request.url}',
            );
          }
          _webViewBloc.add(WebViewError(error: error.description));
        } else {
          // Log sub-frame errors for debugging but don't show error page
          if (kDebugMode) {
            debugPrint(
              '⚠️ Sub-frame error (ignored): ${error.description} for URL: ${request.url}',
            );
          }
        }
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        // Only handle main frame HTTP errors, ignore sub-frame/resource errors
        if (request.isForMainFrame == true) {
          if (kDebugMode) {
            debugPrint(
              '❌ Main frame HTTP error: ${errorResponse.statusCode} ${errorResponse.reasonPhrase} for URL: ${request.url}',
            );
          }
          _webViewBloc.add(
            WebViewError(
              error:
                  'HTTP Error ${errorResponse.statusCode}: ${errorResponse.reasonPhrase}',
            ),
          );
        } else {
          // Log sub-frame HTTP errors for debugging but don't show error page
          if (kDebugMode) {
            debugPrint(
              '⚠️ Sub-frame HTTP error (ignored): ${errorResponse.statusCode} ${errorResponse.reasonPhrase} for URL: ${request.url}',
            );
          }
        }
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        // Accept all SSL certificates for shopping platforms
        // In production, you might want to implement proper certificate validation
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },
      shouldInterceptRequest: (controller, request) async {
        final url = request.url.toString().toLowerCase();

        // List of ad/tracker domains to block
        final blockedDomains = [
          'amazon-adsystem.com',
          'bluekai.com',
          'serving-sys.com',
          'tremorhub.com',
          'googleadservices.com',
          'googlesyndication.com',
          'doubleclick.net',
          'facebook.com/tr',
          'google-analytics.com',
          'googletagmanager.com',
          'scorecardresearch.com',
          'quantserve.com',
          'outbrain.com',
          'taboola.com',
          'adsystem.com',
          'adsystem.amazon.com',
        ];

        // Check if the URL contains any blocked domains
        for (final domain in blockedDomains) {
          if (url.contains(domain)) {
            if (kDebugMode) {
              debugPrint('🚫 Blocked request to: $url');
            }
            // Return empty response to block the request
            return WebResourceResponse(
              contentType: 'text/plain',
              data: Uint8List(0),
            );
          }
        }

        // Allow the request to proceed normally
        return null;
      },
      onLoadResource: (controller, resource) {
        if (kDebugMode) {
          debugPrint('📦 Loading resource: ${resource.url}');
        }
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url.toString();

        if (kDebugMode) {
          debugPrint('🔗 Navigation request: $url');
          debugPrint('🔗 Navigation type: ${navigationAction.navigationType}');
          debugPrint(
            '🔗 Is for main frame: ${navigationAction.isForMainFrame}',
          );
        }

        // Enhanced navigation handling for e-commerce platforms
        final allowedDomains = [
          'shein.com',
          'taobao.com',
          'alibaba.com',
          'aliexpress.com',
          'amazon.com',
          'amazonaws.com', // For Amazon CDN
          'alicdn.com', // For Alibaba CDN
          'tbcdn.cn', // For Taobao CDN
          'sheinstatic.com', // For SHEIN CDN
        ];

        // Check if URL belongs to allowed domains
        final isAllowedDomain = allowedDomains.any(
          (domain) => url.contains(domain),
        );

        if (isAllowedDomain) {
          // Allow navigation but inject scripts for better compatibility
          if (navigationAction.isForMainFrame == true) {
            // Delay script injection to ensure page is ready
            Future.delayed(const Duration(milliseconds: 500), () async {
              try {
                await _injectCompatibilityScripts(controller);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('⚠️ Error injecting scripts on navigation: $e');
                }
              }
            });
          }
          return NavigationActionPolicy.ALLOW;
        }

        // Block external redirects and app store links
        if (url.startsWith('intent://') ||
            url.startsWith('market://') ||
            url.startsWith('mailto:') ||
            url.startsWith('tel:') ||
            url.startsWith('app://') ||
            url.contains('play.google.com') ||
            url.contains('apps.apple.com')) {
          if (kDebugMode) {
            debugPrint('🚫 Blocked external URL: $url');
          }
          return NavigationActionPolicy.CANCEL;
        }

        // Allow HTTPS and HTTP URLs for general browsing
        if (url.startsWith('https://') || url.startsWith('http://')) {
          return NavigationActionPolicy.ALLOW;
        }

        // Block everything else
        if (kDebugMode) {
          debugPrint('🚫 Blocked unknown URL scheme: $url');
        }
        return NavigationActionPolicy.CANCEL;
      },
    );
  }

  String _getEnhancedUserAgent() {
    // Enhanced User-Agent with better bot detection evasion
    final url = widget.initialUrl.toLowerCase();

    if (url.contains('shein.com')) {
      // SHEIN: Use latest iPhone Safari with realistic device info
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1';
    } else if (url.contains('taobao.com')) {
      // Taobao: Use Chrome Mobile with Chinese locale hints
      return 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36';
    } else if (url.contains('alibaba.com')) {
      // Alibaba: Use desktop Chrome to avoid mobile restrictions
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36';
    } else if (url.contains('aliexpress.com')) {
      // AliExpress: Use latest Chrome Mobile
      return 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36';
    } else if (url.contains('amazon.com')) {
      // Amazon: Use Safari Mobile for better compatibility
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1';
    } else {
      // Default: Latest Chrome Mobile with realistic device
      return 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36';
    }
  }

  Future<void> _configureEnhancedCookies() async {
    try {
      final cookieManager = CookieManager.instance();

      // Enhanced cookie configuration for better session handling
      final cookieConfigs = [
        {
          'url': 'https://www.shein.com',
          'domain': '.shein.com',
          'name': 'webview_session',
        },
        {
          'url': 'https://world.taobao.com',
          'domain': '.taobao.com',
          'name': 'webview_session',
        },
        {
          'url': 'https://www.alibaba.com',
          'domain': '.alibaba.com',
          'name': 'webview_session',
        },
        {
          'url': 'https://www.aliexpress.com',
          'domain': '.aliexpress.com',
          'name': 'webview_session',
        },
        {
          'url': 'https://www.amazon.com',
          'domain': '.amazon.com',
          'name': 'webview_session',
        },
      ];

      for (final config in cookieConfigs) {
        await cookieManager.setCookie(
          url: WebUri(config['url']!),
          name: config['name']!,
          value: 'enabled_${DateTime.now().millisecondsSinceEpoch}',
          domain: config['domain']!,
          isSecure: true,
          isHttpOnly: false,
          sameSite: HTTPCookieSameSitePolicy.LAX,
          maxAge: 86400, // 24 hours
        );

        // Set additional cookies for better compatibility
        await cookieManager.setCookie(
          url: WebUri(config['url']!),
          name: 'mobile_app',
          value: 'true',
          domain: config['domain']!,
          isSecure: true,
          isHttpOnly: false,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        );
      }

      if (kDebugMode) {
        debugPrint('🍪 Enhanced cookies configured for e-commerce platforms');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error configuring enhanced cookies: $e');
      }
    }
  }

  Future<void> _injectCompatibilityScripts(
    InAppWebViewController controller,
  ) async {
    try {
      // JavaScript to enhance compatibility and reduce bot detection
      const compatibilityScript = '''
        (function() {
          // Override navigator properties to appear more like a real browser
          Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined,
          });

          // Add realistic screen properties
          Object.defineProperty(screen, 'availWidth', {
            get: () => window.innerWidth,
          });

          Object.defineProperty(screen, 'availHeight', {
            get: () => window.innerHeight,
          });

          // Add realistic timing
          const originalPerformanceNow = performance.now;
          performance.now = function() {
            return originalPerformanceNow.call(this) + Math.random() * 0.1;
          };

          // Enhance touch events for mobile compatibility
          if (!window.TouchEvent) {
            window.TouchEvent = function() {};
          }

          // Add mobile-specific properties
          Object.defineProperty(navigator, 'maxTouchPoints', {
            get: () => 5,
          });

          // Prevent some common bot detection methods
          delete window.callPhantom;
          delete window._phantom;
          delete window.__nightmare;

          console.log('🚀 Compatibility scripts injected successfully');
        })();
      ''';

      await controller.evaluateJavascript(source: compatibilityScript);

      if (kDebugMode) {
        debugPrint('🚀 Compatibility scripts injected');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error injecting compatibility scripts: $e');
      }
    }
  }

  Future<void> _injectPostLoadScripts(
    InAppWebViewController controller,
    String url,
  ) async {
    try {
      // Site-specific post-load scripts for better compatibility
      String postLoadScript = '';

      if (url.contains('shein.com')) {
        postLoadScript = '''
          (function() {
            // SHEIN-specific enhancements
            if (window.location.href.includes('shein.com')) {
              // Enhance mobile touch events
              document.addEventListener('touchstart', function() {}, {passive: true});
              document.addEventListener('touchmove', function() {}, {passive: true});

              // Override some SHEIN bot detection
              if (window.navigator && window.navigator.userAgent) {
                Object.defineProperty(navigator, 'platform', {
                  get: () => 'iPhone',
                });
              }

              console.log('🛍️ SHEIN compatibility enhanced');
            }
          })();
        ''';
      } else if (url.contains('taobao.com') || url.contains('alibaba.com')) {
        postLoadScript = '''
          (function() {
            // Taobao/Alibaba-specific enhancements
            if (window.location.href.includes('taobao.com') || window.location.href.includes('alibaba.com')) {
              // Add Chinese locale support
              Object.defineProperty(navigator, 'language', {
                get: () => 'zh-CN',
              });

              Object.defineProperty(navigator, 'languages', {
                get: () => ['zh-CN', 'zh', 'en'],
              });

              // Enhance timezone for Chinese sites
              try {
                Intl.DateTimeFormat().resolvedOptions = function() {
                  return { timeZone: 'Asia/Shanghai' };
                };
              } catch(e) {}

              console.log('🏮 Chinese e-commerce compatibility enhanced');
            }
          })();
        ''';
      } else if (url.contains('aliexpress.com')) {
        postLoadScript = '''
          (function() {
            // AliExpress-specific enhancements
            if (window.location.href.includes('aliexpress.com')) {
              // Enhance mobile viewport
              const viewport = document.querySelector('meta[name="viewport"]');
              if (viewport) {
                viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, user-scalable=yes');
              }

              // Add mobile app indicators
              window.isWebView = true;
              window.isMobileApp = true;

              console.log('🛒 AliExpress compatibility enhanced');
            }
          })();
        ''';
      }

      if (postLoadScript.isNotEmpty) {
        await controller.evaluateJavascript(source: postLoadScript);

        if (kDebugMode) {
          debugPrint('🎯 Site-specific scripts injected for: $url');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error injecting post-load scripts: $e');
      }
    }
  }

  Future<void> _clearWebViewData() async {
    if (_webViewController != null) {
      await InAppWebViewController.clearAllCache();
      await CookieManager.instance().deleteAllCookies();
      // Note: WebViewDataCleared is not a WebViewEvent, we need to handle this differently
      // For now, we'll just clear the data without emitting an event
    }
  }
}
