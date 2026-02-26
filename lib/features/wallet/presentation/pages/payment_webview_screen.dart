import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/wallet_bloc.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;
  final String userId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.transactionId,
    required this.userId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0.0;
  bool _isLoading = true;
  Timer? _autoCloseTimer;
  bool _isDialogOpen = false;

  @override
  void dispose() {
    // Cancel auto-close timer if it's still running
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🏗️ PaymentWebViewScreen build called');
    }

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (kDebugMode) {
          debugPrint('🔔 BlocListener received state: ${state.runtimeType}');
        }

        // Listen for payment completion
        if (state is WalletTopUpCompleted) {
          if (kDebugMode) {
            debugPrint('✅ Payment completed! Closing payment webview...');
            debugPrint('   Transaction ID: ${state.transactionId}');
          }

          // Cancel timer
          _autoCloseTimer?.cancel();
          if (kDebugMode) {
            debugPrint('   Timer cancelled');
          }

          // Close dialog first (if open), then close webview
          _closePaymentFlow(context);
        } else if (state is WalletTopUpError) {
          if (kDebugMode) {
            debugPrint('❌ Payment error: ${state.message}');
          }

          // Cancel timer
          _autoCloseTimer?.cancel();

          // Show error and close
          _showErrorDialog(state.message);
        }
      },
      child: Scaffold(
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
    // ZainCash v2 redirects to our Supabase Edge Function
    // Example: https://[PROJ].supabase.co/functions/v1/zaincash-topup?status=success&...
    final isSupabaseFunction = url.contains(
      'supabase.co/functions/v1/zaincash-topup',
    );

    if (isSupabaseFunction) return true;

    // Fallback for other ZainCash common indicators
    return url.contains('success') ||
        url.contains('failure') ||
        url.contains('cancel');
  }

  void _checkForPaymentCompletion(String url) {
    // Check if the URL indicates payment completion
    if (_isPaymentCallbackUrl(url)) {
      _handlePaymentCallback(url);
    }
  }

  void _handlePaymentCallback(String url) {
    final uri = Uri.parse(url);
    final status = uri.queryParameters['status'];
    final externalReferenceId = uri.queryParameters['externalReferenceId'];

    if (kDebugMode) {
      debugPrint('💳 Payment callback detected: $url');
      debugPrint('   Status: $status');
      debugPrint('   External Reference ID: $externalReferenceId');
    }

    if (status == 'success') {
      // Payment successful
      // The backend has already been called via the redirect, so we just need to verify and refresh.
      context.read<WalletBloc>().add(
        WalletTransactionStatusChecked(
          transactionId: externalReferenceId ?? widget.transactionId,
        ),
      );
      _showPaymentCompletionDialog(isSuccess: true);
    } else {
      // Payment failed or cancelled
      _showPaymentCompletionDialog(isSuccess: false);
    }
  }

  void _showPaymentCompletionDialog({required bool isSuccess}) {
    if (kDebugMode) {
      debugPrint('💬 Showing payment completion dialog (Success: $isSuccess)');
    }

    // Cancel any existing timer
    _autoCloseTimer?.cancel();
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(isSuccess ? 'تم الدفع بنجاح' : 'فشل الدفع'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  isSuccess
                      ? 'تم شحن محفظتك بنجاح. جاري تحديث الرصيد...'
                      : 'حدث خطأ أثناء عملية الدفع. يرجى المحاولة مرة أخرى.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _autoCloseTimer?.cancel();
                  _isDialogOpen = false;
                  Navigator.of(dialogContext).pop();
                  _closePaymentFlow(context);
                },
                child: const Text('موافق'),
              ),
            ],
          ),
    );

    // Auto-close dialog after a delay on success
    if (isSuccess) {
      _autoCloseTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isDialogOpen) {
          _isDialogOpen = false;
          Navigator.of(context, rootNavigator: false).pop();
          _closePaymentFlow(context);
        }
      });
    }
  }

  void _closePaymentFlow(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🔙 _closePaymentFlow called');
      debugPrint('   _isDialogOpen: $_isDialogOpen');
      debugPrint('   mounted: $mounted');
      debugPrint('   canPop: ${Navigator.of(context).canPop()}');
    }

    // Dispatch event to reset wallet state
    if (kDebugMode) {
      debugPrint('   Dispatching WalletTopUpSessionClosed event...');
    }
    context.read<WalletBloc>().add(
      WalletTopUpSessionClosed(
        userId: widget.userId,
        transactionId: widget.transactionId,
      ),
    );

    // Close dialog if it's open
    if (_isDialogOpen) {
      if (kDebugMode) {
        debugPrint('   Closing dialog...');
      }
      _isDialogOpen = false;

      // Use try-catch to safely close dialog
      try {
        Navigator.of(context, rootNavigator: false).pop();
        if (kDebugMode) {
          debugPrint('   ✅ Dialog closed successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ⚠️ Error closing dialog: $e');
        }
      }
    }

    // Close webview using GoRouter-compatible navigation
    if (mounted) {
      if (kDebugMode) {
        debugPrint('   Closing webview...');
      }

      // Use try-catch to safely close webview
      try {
        // Try GoRouter's pop first
        if (context.canPop()) {
          context.pop();
          if (kDebugMode) {
            debugPrint('   ✅ WebView closed with context.pop()');
          }
        } else if (Navigator.of(context).canPop()) {
          // Fallback to Navigator.pop if GoRouter can't pop
          Navigator.of(context).pop();
          if (kDebugMode) {
            debugPrint('   ✅ WebView closed with Navigator.pop()');
          }
        } else {
          if (kDebugMode) {
            debugPrint('   ⚠️ Cannot pop - navigation stack is empty');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ❌ Error closing webview: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('🔙 _closePaymentFlow completed');
    }
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
    if (kDebugMode) {
      debugPrint('💬 Showing exit confirmation dialog');
    }

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('إلغاء الدفع'),
            content: const Text('هل أنت متأكد من إلغاء عملية الدفع؟'),
            actions: [
              TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    debugPrint('👆 User clicked "لا" (No)');
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('لا'),
              ),
              TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    debugPrint(
                      '👆 User clicked "نعم" (Yes) - Cancelling payment',
                    );
                  }

                  // Cancel timer when user closes payment
                  _autoCloseTimer?.cancel();
                  _isDialogOpen = false;

                  // Dispatch event to reset wallet state
                  if (kDebugMode) {
                    debugPrint(
                      '   Dispatching WalletTopUpSessionClosed event...',
                    );
                  }
                  context.read<WalletBloc>().add(
                    WalletTopUpSessionClosed(
                      userId: widget.userId,
                      transactionId: widget.transactionId,
                    ),
                  );

                  // Close confirmation dialog
                  try {
                    Navigator.of(dialogContext).pop();
                    if (kDebugMode) {
                      debugPrint('   ✅ Confirmation dialog closed');
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint('   ❌ Error closing confirmation dialog: $e');
                    }
                  }

                  // Close webview using safe navigation
                  if (mounted) {
                    try {
                      if (context.canPop()) {
                        context.pop();
                        if (kDebugMode) {
                          debugPrint('   ✅ WebView closed with context.pop()');
                        }
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                        if (kDebugMode) {
                          debugPrint(
                            '   ✅ WebView closed with Navigator.pop()',
                          );
                        }
                      } else {
                        if (kDebugMode) {
                          debugPrint(
                            '   ⚠️ Cannot pop - navigation stack is empty',
                          );
                        }
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        debugPrint('   ❌ Error closing webview: $e');
                      }
                    }
                  }
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
