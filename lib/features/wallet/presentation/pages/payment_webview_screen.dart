import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/wallet_bloc.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.transactionId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0.0;
  bool _isLoading = true;
  String? _currentUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الدفع عبر زين كاش', style: AppTextStyles.titleMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: _showExitConfirmation,
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            onPressed: _refreshPage,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          // WebView content
          Expanded(child: _buildWebView()),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        userAgent: _getEnhancedUserAgent(),
        mixedContentMode: MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        clearCache: false,
        cacheEnabled: true,
        supportZoom: false,
        displayZoomControls: false,
        builtInZoomControls: false,
        useOnLoadResource: true,
        useShouldOverrideUrlLoading: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        if (kDebugMode) {
          debugPrint(
            '🌐 Payment WebView created for URL: ${widget.paymentUrl}',
          );
        }
      },
      onLoadStart: (controller, url) {
        if (url != null) {
          setState(() {
            _currentUrl = url.toString();
            _isLoading = true;
          });

          if (kDebugMode) {
            debugPrint('🔄 Payment WebView started loading: ${url.toString()}');
          }
        }
      },
      onLoadStop: (controller, url) {
        if (url != null) {
          setState(() {
            _currentUrl = url.toString();
            _isLoading = false;
          });

          if (kDebugMode) {
            debugPrint('✅ Payment WebView finished loading: ${url.toString()}');
          }

          _checkForPaymentCompletion(url.toString());
        }
      },
      onProgressChanged: (controller, progress) {
        setState(() {
          _progress = progress / 100.0;
        });
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url.toString();

        if (kDebugMode) {
          debugPrint('🔍 Payment WebView navigation to: $url');
        }

        // Check for payment completion or callback URLs
        if (_isPaymentCallbackUrl(url)) {
          _handlePaymentCallback(url);
          return NavigationActionPolicy.CANCEL;
        }

        return NavigationActionPolicy.ALLOW;
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame == true) {
          if (kDebugMode) {
            debugPrint('❌ Payment WebView error: ${error.description}');
          }

          _showErrorDialog(error.description);
        }
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        if (request.isForMainFrame == true) {
          if (kDebugMode) {
            debugPrint(
              '❌ Payment WebView HTTP error: ${errorResponse.statusCode}',
            );
          }
        }
      },
    );
  }

  String _getEnhancedUserAgent() {
    return 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';
  }

  bool _isPaymentCallbackUrl(String url) {
    // Check for ZainCash callback URLs or success/failure indicators
    return url.contains('callback') ||
        url.contains('success') ||
        url.contains('failure') ||
        url.contains('cancel') ||
        url.contains('return') ||
        url.contains('redirect');
  }

  void _checkForPaymentCompletion(String url) {
    // Check if the URL indicates payment completion
    if (_isPaymentCallbackUrl(url)) {
      _handlePaymentCallback(url);
    }
  }

  void _handlePaymentCallback(String url) {
    if (kDebugMode) {
      debugPrint('💳 Payment callback detected: $url');
    }

    // Check transaction status
    context.read<WalletBloc>().add(
      WalletTransactionStatusChecked(transactionId: widget.transactionId),
    );

    // Show completion dialog
    _showPaymentCompletionDialog();
  }

  void _showPaymentCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('معالجة الدفع'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('جاري التحقق من حالة الدفع...'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close WebView
                },
                child: const Text('العودة للمحفظة'),
              ),
            ],
          ),
    );

    // Auto-close after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Close WebView
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('خطأ في التحميل'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('موافق'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _refreshPage();
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إلغاء الدفع'),
            content: const Text('هل أنت متأكد من إلغاء عملية الدفع؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('لا'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close WebView
                },
                child: const Text('نعم'),
              ),
            ],
          ),
    );
  }

  void _refreshPage() {
    _webViewController?.reload();
  }
}
