import '../../domain/entities/webview_state.dart';

/// Data model for WebViewState with JSON serialization
class WebViewStateModel extends WebViewState {
  const WebViewStateModel({
    required super.url,
    required super.title,
    super.isLoading,
    super.progress,
    super.canGoBack,
    super.canGoForward,
    super.error,
  });

  factory WebViewStateModel.fromJson(Map<String, dynamic> json) {
    return WebViewStateModel(
      url: json['url'] as String,
      title: json['title'] as String,
      isLoading: json['isLoading'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      canGoBack: json['canGoBack'] as bool? ?? false,
      canGoForward: json['canGoForward'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'isLoading': isLoading,
      'progress': progress,
      'canGoBack': canGoBack,
      'canGoForward': canGoForward,
      'error': error,
    };
  }

  factory WebViewStateModel.fromEntity(WebViewState state) {
    return WebViewStateModel(
      url: state.url,
      title: state.title,
      isLoading: state.isLoading,
      progress: state.progress,
      canGoBack: state.canGoBack,
      canGoForward: state.canGoForward,
      error: state.error,
    );
  }
}
