import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../cart/data/platform_selectors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
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
  late CartBloc _cartBloc;

  // Track navigation to prevent infinite loops
  final Set<String> _visitedUrls = <String>{};
  String? _lastLoadedUrl;
  int _navigationCount = 0;

  @override
  void initState() {
    super.initState();
    _webViewBloc = di.sl<WebViewBloc>();
    _cartBloc = di.sl<CartBloc>();
    // Clean and load the initial URL (handles deep links)
    final cleanedUrl = _cleanUrl(widget.initialUrl);
    _webViewBloc.add(WebViewLoadUrl(url: cleanedUrl));
  }

  @override
  void dispose() {
    _webViewBloc.close();
    _cartBloc.close();
    super.dispose();
  }

  /// Clean and extract real URL from deep links
  String _cleanUrl(String url) {
    // Check if it's a deep link
    if (url.startsWith('aliexpress://') ||
        url.startsWith('shein://') ||
        url.startsWith('amazon://') ||
        url.startsWith('taobao://') ||
        url.startsWith('alibaba://') ||
        url.startsWith('temu://')) {
      return _extractRealUrl(url);
    }

    return url;
  }

  /// Extract real HTTPS URL from deep link
  String _extractRealUrl(String deepLink) {
    try {
      final uri = Uri.parse(deepLink);

      // Try to extract 'url' parameter
      final encodedUrl = uri.queryParameters['url'];

      if (encodedUrl != null) {
        final decodedUrl = Uri.decodeComponent(encodedUrl);
        if (kDebugMode) {
          print('✅ Extracted URL from deep link: $decodedUrl');
        }
        return decodedUrl;
      }

      // Fallback: Try to find any https URL in the string
      final httpsMatch = RegExp(r'https?://[^\s&]+').firstMatch(deepLink);
      if (httpsMatch != null) {
        final extractedUrl = Uri.decodeComponent(httpsMatch.group(0)!);
        if (kDebugMode) {
          print('✅ Extracted URL via regex: $extractedUrl');
        }
        return extractedUrl;
      }

      // Last resort: Return platform homepage
      return _getPlatformHomepage(deepLink);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error extracting URL: $e');
      }
      return _getPlatformHomepage(deepLink);
    }
  }

  /// Get platform homepage as fallback
  String _getPlatformHomepage(String deepLink) {
    if (deepLink.contains('aliexpress')) {
      return 'https://www.aliexpress.com';
    } else if (deepLink.contains('shein')) {
      return 'https://www.shein.com';
    } else if (deepLink.contains('amazon')) {
      return 'https://www.amazon.com';
    } else if (deepLink.contains('taobao')) {
      return 'https://www.taobao.com';
    } else if (deepLink.contains('alibaba')) {
      return 'https://www.alibaba.com';
    } else if (deepLink.contains('temu')) {
      return 'https://www.temu.com';
    }
    return 'https://www.google.com';
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
    // Clean the URL before loading (handles deep links)
    final cleanedUrl = _cleanUrl(widget.initialUrl);

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(cleanedUrl)),
      initialSettings: InAppWebViewSettings(
        // Enhanced JavaScript settings for modern e-commerce sites
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        domStorageEnabled: true,
        databaseEnabled: true,

        // Enhanced User-Agent for better compatibility
        userAgent: _getEnhancedUserAgent(),
        applicationNameForUserAgent:
            '', // Don't add "wv" suffix to avoid WebView detection
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

        // Error handling
        disableDefaultErrorPage: true,

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
      ),
      onWebViewCreated: (controller) async {
        _webViewController = controller;

        // Add JavaScript channel for cart communication
        controller.addJavaScriptHandler(
          handlerName: 'FlutterCartChannel',
          callback: (args) {
            if (args.isNotEmpty) {
              _handleCartData(args[0]);
            }
          },
        );

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

          // Inject anti-detection scripts for SHEIN
          if (url.toString().toLowerCase().contains('shein.com')) {
            await _injectAntiDetectionScripts(controller);
          }

          // Wait longer for SHEIN dynamic content to load
          if (url.toString().toLowerCase().contains('shein.com')) {
            if (kDebugMode) {
              debugPrint('⏳ Waiting 3 seconds for SHEIN dynamic content...');
            }
            await Future.delayed(const Duration(seconds: 3));
          }

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

        // Force stop loading for SHEIN after timeout when progress > 80%
        if (widget.initialUrl.toLowerCase().contains('shein.com') &&
            progress > 80) {
          Future.delayed(const Duration(seconds: 5), () async {
            final currentProgress = await controller.getProgress();
            if (currentProgress != null && currentProgress < 100) {
              if (kDebugMode) {
                debugPrint(
                  '⚠️ Forced loading stop for SHEIN (progress: $currentProgress%)',
                );
              }
              await controller.stopLoading();
            }
          });
        }
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
        final url = request.url.toString();

        // Ignore tracking/analytics failures (especially for SHEIN)
        if (url.contains('srmdata') ||
            url.contains('cinfo') ||
            url.contains('analytics') ||
            url.contains('tracking') ||
            url.contains('beacon') ||
            url.contains('metric')) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ Ignored tracking error: $url (${errorResponse.statusCode})',
            );
          }
          return; // Don't show error or block page
        }

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

        // Handle deep links from e-commerce apps
        if (url.startsWith('aliexpress://') ||
            url.startsWith('shein://') ||
            url.startsWith('amazon://') ||
            url.startsWith('taobao://') ||
            url.startsWith('alibaba://') ||
            url.startsWith('temu://')) {
          final cleanedUrl = _cleanUrl(url);
          if (kDebugMode) {
            debugPrint('🔄 Deep link detected, redirecting to: $cleanedUrl');
          }

          // Load the cleaned URL
          await controller.loadUrl(
            urlRequest: URLRequest(url: WebUri(cleanedUrl)),
          );
          return NavigationActionPolicy.CANCEL;
        }

        // Enhanced navigation handling for e-commerce platforms
        final allowedDomains = [
          'shein.com',
          'taobao.com',
          'alibaba.com',
          'aliexpress.com',
          'amazon.com',
          'temu.com',
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
      onConsoleMessage: (controller, consoleMessage) {
        // Enhanced console logging for debugging
        if (kDebugMode) {
          final level = consoleMessage.messageLevel;
          final message = consoleMessage.message;

          if (level == ConsoleMessageLevel.ERROR) {
            debugPrint('❌ JS Error: $message');

            // Special logging for SHEIN errors
            if (widget.initialUrl.toLowerCase().contains('shein.com')) {
              debugPrint('❌ SHEIN JS Error: $message');
            }
          } else if (level == ConsoleMessageLevel.WARNING) {
            debugPrint('⚠️ JS Warning: $message');
          } else if (level == ConsoleMessageLevel.LOG) {
            debugPrint('📝 JS Log: $message');
          }
        }
      },
      onCreateWindow: (controller, createWindowAction) async {
        // Handle popup windows (critical for AliExpress and other platforms)
        final url = createWindowAction.request.url?.toString();

        if (kDebugMode) {
          debugPrint('🪟 onCreateWindow called for URL: $url');
        }

        if (url != null && url.isNotEmpty) {
          // Load the URL in the same WebView instead of creating a new window
          await controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));

          if (kDebugMode) {
            debugPrint('✅ Loaded popup URL in same WebView: $url');
          }
        }

        // Return true to indicate we handled the window creation
        return true;
      },
    );
  }

  String _getEnhancedUserAgent() {
    // Enhanced User-Agent with better bot detection evasion
    final url = widget.initialUrl.toLowerCase();

    if (url.contains('shein.com')) {
      // SHEIN: Use Android Chrome to avoid user-agent mismatch detection
      return 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36';
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

          // Override window.open to prevent popup issues (critical for AliExpress)
          const originalWindowOpen = window.open;
          window.open = function(url, target, features) {
            console.log('🪟 window.open intercepted:', url);

            // If URL is provided, navigate to it in the same window
            if (url) {
              window.location.href = url;
              return window;
            }

            // Otherwise, try the original function
            return originalWindowOpen.call(this, url, target, features);
          };

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

  Future<void> _injectAntiDetectionScripts(
    InAppWebViewController controller,
  ) async {
    try {
      // Anti-detection JavaScript specifically for SHEIN
      const antiDetectionScript = '''
        (function() {
          console.log('🛡️ Injecting anti-detection scripts for SHEIN');

          // Remove webdriver property
          Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined
          });

          // Remove WebView indicators
          delete navigator.__proto__.webdriver;

          // Override chrome property to appear like real Chrome
          if (!window.chrome) {
            window.chrome = {
              runtime: {},
              loadTimes: function() {},
              csi: function() {},
              app: {}
            };
          }

          // Override permissions
          const originalQuery = window.navigator.permissions.query;
          window.navigator.permissions.query = (parameters) => (
            parameters.name === 'notifications' ?
              Promise.resolve({ state: Notification.permission }) :
              originalQuery(parameters)
          );

          // Override plugins to appear like real browser
          Object.defineProperty(navigator, 'plugins', {
            get: () => [1, 2, 3, 4, 5]
          });

          // Override languages
          Object.defineProperty(navigator, 'languages', {
            get: () => ['en-US', 'en']
          });

          console.log('✅ Anti-detection scripts injected successfully');
        })();
      ''';

      await controller.evaluateJavascript(source: antiDetectionScript);

      if (kDebugMode) {
        debugPrint('🛡️ Anti-detection scripts injected for SHEIN');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error injecting anti-detection scripts: $e');
      }
    }
  }

  Future<void> _injectPostLoadScripts(
    InAppWebViewController controller,
    String url,
  ) async {
    try {
      // Small delay to ensure page is fully rendered
      await Future.delayed(const Duration(milliseconds: 1000));

      // Inject cart button for all e-commerce platforms
      await _injectCartButton(controller, url);

      // Site-specific post-load scripts for better compatibility
      String postLoadScript = '';

      if (url.contains('taobao.com') || url.contains('alibaba.com')) {
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

  /// Inject cart button into the page
  Future<void> _injectCartButton(
    InAppWebViewController controller,
    String url,
  ) async {
    try {
      // Determine platform from URL
      String platform = 'generic';
      if (url.contains('amazon.com')) {
        platform = 'amazon';
      } else if (url.contains('shein.com')) {
        platform = 'shein';
      } else if (url.contains('aliexpress.com')) {
        platform = 'aliexpress';
      } else if (url.contains('taobao.com')) {
        platform = 'taobao';
      } else if (url.contains('alibaba.com')) {
        platform = 'alibaba';
      }

      // Get platform-specific selectors
      final selectors = PlatformSelectors.getSelectors(platform);
      final buttonColor = selectors['buttonColor'] ?? '#213c86';

      // Generate extraction script
      final extractionScript = PlatformSelectors.generateExtractionScript(
        platform,
      );

      // Complete cart button script
      final cartButtonScript = '''
        (function() {
          console.log('🚀 Starting cart button injection for platform: $platform');

          // Remove existing button if any
          const existingButton = document.getElementById('flutter-cart-btn');
          if (existingButton) {
            console.log('🗑️ Removing existing cart button');
            existingButton.remove();
          }

          $extractionScript

          // Create floating cart button
          const button = document.createElement('div');
          button.id = 'flutter-cart-btn';
          button.innerHTML = '🛒 إضافة للسلة';
          button.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: $buttonColor;
            color: white;
            padding: 15px 25px;
            border-radius: 50px;
            cursor: pointer;
            z-index: 999999;
            font-weight: bold;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            transition: transform 0.2s, box-shadow 0.2s;
          `;

          // Add hover effect
          button.addEventListener('mouseenter', function() {
            button.style.transform = 'scale(1.05)';
            button.style.boxShadow = '0 6px 16px rgba(0,0,0,0.4)';
          });

          button.addEventListener('mouseleave', function() {
            button.style.transform = 'scale(1)';
            button.style.boxShadow = '0 4px 12px rgba(0,0,0,0.3)';
          });

          // Append button to body
          document.body.appendChild(button);
          console.log('✅ Cart button added to DOM');

          // Handle button click (async to support waiting for elements)
          button.addEventListener('click', async function() {
            try {
              button.innerHTML = '⏳ جاري الإضافة...';
              button.style.pointerEvents = 'none';

              // Extract product data (now async)
              const productData = await extractProductData();

              // Send to Flutter via JavaScript handler
              window.flutter_inappwebview.callHandler('FlutterCartChannel', productData)
                .then(function(result) {
                  button.innerHTML = '✅ تمت الإضافة';
                  setTimeout(function() {
                    button.innerHTML = '🛒 إضافة للسلة';
                    button.style.pointerEvents = 'auto';
                  }, 2000);
                })
                .catch(function(error) {
                  console.error('Error sending to Flutter:', error);
                  button.innerHTML = '❌ فشل';
                  setTimeout(function() {
                    button.innerHTML = '🛒 إضافة للسلة';
                    button.style.pointerEvents = 'auto';
                  }, 2000);
                });
            } catch (error) {
              console.error('Error extracting product data:', error);
              button.innerHTML = '❌ خطأ';
              setTimeout(function() {
                button.innerHTML = '🛒 إضافة للسلة';
                button.style.pointerEvents = 'auto';
              }, 2000);
            }
          });

          console.log('🛒 Cart button injected successfully for platform: $platform');
        })();
      ''';

      await controller.evaluateJavascript(source: cartButtonScript);

      if (kDebugMode) {
        debugPrint('🛒 Cart button injected for platform: $platform');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error injecting cart button: $e');
      }
    }
  }

  /// Handle cart data received from JavaScript
  void _handleCartData(dynamic data) {
    try {
      if (kDebugMode) {
        debugPrint('📦 Received cart data: $data');
      }

      Map<String, dynamic> productData;

      if (data is String) {
        productData = jsonDecode(data);
      } else if (data is Map) {
        productData = Map<String, dynamic>.from(data);
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Invalid cart data type: ${data.runtimeType}');
        }
        return;
      }

      // Validate required fields
      if (productData['title'] == null ||
          productData['title'].toString().isEmpty ||
          productData['title'] == 'No title found') {
        _showSnackBar('لم نتمكن من استخراج بيانات المنتج', isError: true);
        return;
      }

      // Add to cart via BLoC
      _cartBloc.add(
        CartAddItem(
          productName: productData['title'] ?? 'Unknown Product',
          price: productData['price'] ?? 'Price not available',
          imageUrl: productData['image'],
          images:
              productData['images'] != null
                  ? List<String>.from(productData['images'])
                  : null,
          productUrl: productData['url'] ?? '',
          platform: productData['platform'] ?? 'unknown',
          rating: productData['rating'],
          metadata: productData,
        ),
      );

      _showSnackBar('تمت إضافة المنتج للسلة بنجاح');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error handling cart data: $e');
      }
      _showSnackBar('حدث خطأ أثناء إضافة المنتج', isError: true);
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
