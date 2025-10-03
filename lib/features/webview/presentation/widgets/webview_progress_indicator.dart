import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/webview_bloc.dart';
import '../bloc/webview_state.dart';

/// Progress indicator for WebView loading
class WebViewProgressIndicator extends StatelessWidget {
  const WebViewProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebViewBloc, WebViewBlocState>(
      builder: (context, state) {
        if (state is WebViewLoading) {
          return SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: state.progress,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
