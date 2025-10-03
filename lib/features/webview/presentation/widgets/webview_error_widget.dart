import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/webview_bloc.dart';
import '../bloc/webview_event.dart';

/// Error widget for WebView failures
class WebViewErrorWidget extends StatelessWidget {
  final String message;
  final String? url;

  const WebViewErrorWidget({super.key, required this.message, this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل الصفحة',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (url != null) ...[
            const SizedBox(height: 8),
            Text(
              url!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة'),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: ElevatedButton.icon(
                  onPressed:
                      url != null
                          ? () => context.read<WebViewBloc>().add(
                            WebViewLoadUrl(url: url!),
                          )
                          : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
