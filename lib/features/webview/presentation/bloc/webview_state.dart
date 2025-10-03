import 'package:equatable/equatable.dart';

/// Base class for all WebView states
abstract class WebViewBlocState extends Equatable {
  const WebViewBlocState();

  @override
  List<Object?> get props => [];
}

/// Initial state of WebView
class WebViewInitial extends WebViewBlocState {
  const WebViewInitial();
}

/// State when WebView is loading
class WebViewLoading extends WebViewBlocState {
  final String url;
  final double progress;

  const WebViewLoading({
    required this.url,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [url, progress];
}

/// State when WebView has loaded successfully
class WebViewLoaded extends WebViewBlocState {
  final String url;
  final String title;
  final bool canGoBack;
  final bool canGoForward;

  const WebViewLoaded({
    required this.url,
    required this.title,
    required this.canGoBack,
    required this.canGoForward,
  });

  WebViewLoaded copyWith({
    String? url,
    String? title,
    bool? canGoBack,
    bool? canGoForward,
  }) {
    return WebViewLoaded(
      url: url ?? this.url,
      title: title ?? this.title,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
    );
  }

  @override
  List<Object?> get props => [url, title, canGoBack, canGoForward];
}

/// State when WebView encounters an error
class WebViewErrorState extends WebViewBlocState {
  final String message;
  final String? url;

  const WebViewErrorState({
    required this.message,
    this.url,
  });

  @override
  List<Object?> get props => [message, url];
}

/// State when WebView is navigating (going back/forward)
class WebViewNavigating extends WebViewBlocState {
  final String currentUrl;
  final bool isGoingBack;

  const WebViewNavigating({
    required this.currentUrl,
    required this.isGoingBack,
  });

  @override
  List<Object?> get props => [currentUrl, isGoingBack];
}

/// State when WebView data is being cleared
class WebViewClearingData extends WebViewBlocState {
  const WebViewClearingData();
}

/// State when WebView data has been cleared
class WebViewDataCleared extends WebViewBlocState {
  const WebViewDataCleared();
}
