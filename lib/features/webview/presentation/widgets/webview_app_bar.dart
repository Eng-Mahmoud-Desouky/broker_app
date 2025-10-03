import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/webview_bloc.dart';
import '../bloc/webview_event.dart';
import '../bloc/webview_state.dart';

/// Custom AppBar for WebView with navigation controls
class WebViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onClose;

  const WebViewAppBar({
    super.key,
    required this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.shadow,
      surfaceTintColor: AppColors.surface,
      leading: IconButton(
        onPressed: onClose ?? () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.close,
          color: AppColors.onSurface,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          BlocBuilder<WebViewBloc, WebViewBlocState>(
            builder: (context, state) {
              if (state is WebViewLoaded && state.url.isNotEmpty) {
                final uri = Uri.tryParse(state.url);
                final domain = uri?.host ?? state.url;
                return Text(
                  domain,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      actions: [
        BlocBuilder<WebViewBloc, WebViewBlocState>(
          builder: (context, state) {
            final bloc = context.read<WebViewBloc>();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back button
                IconButton(
                  onPressed: bloc.canGoBack
                      ? () => bloc.add(const WebViewGoBack())
                      : null,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: bloc.canGoBack
                        ? AppColors.onSurface
                        : AppColors.grey400,
                  ),
                ),
                // Forward button
                IconButton(
                  onPressed: bloc.canGoForward
                      ? () => bloc.add(const WebViewGoForward())
                      : null,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: bloc.canGoForward
                        ? AppColors.onSurface
                        : AppColors.grey400,
                  ),
                ),
                // Reload button
                IconButton(
                  onPressed: () => bloc.add(const WebViewReload()),
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
