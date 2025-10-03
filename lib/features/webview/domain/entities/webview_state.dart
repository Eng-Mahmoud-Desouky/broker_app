import 'package:equatable/equatable.dart';

/// Represents the current state of a WebView
class WebViewState extends Equatable {
  final String url;
  final String title;
  final bool isLoading;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;
  final String? error;

  const WebViewState({
    required this.url,
    required this.title,
    this.isLoading = false,
    this.progress = 0.0,
    this.canGoBack = false,
    this.canGoForward = false,
    this.error,
  });

  WebViewState copyWith({
    String? url,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    String? error,
  }) {
    return WebViewState(
      url: url ?? this.url,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        url,
        title,
        isLoading,
        progress,
        canGoBack,
        canGoForward,
        error,
      ];
}
