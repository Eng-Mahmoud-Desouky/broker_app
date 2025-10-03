import 'package:equatable/equatable.dart';

/// Base class for all WebView events
abstract class WebViewEvent extends Equatable {
  const WebViewEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a URL in the WebView
class WebViewLoadUrl extends WebViewEvent {
  final String url;

  const WebViewLoadUrl({required this.url});

  @override
  List<Object?> get props => [url];
}

/// Event when WebView starts loading
class WebViewStartedLoading extends WebViewEvent {
  final String url;

  const WebViewStartedLoading({required this.url});

  @override
  List<Object?> get props => [url];
}

/// Event when WebView finishes loading
class WebViewFinishedLoading extends WebViewEvent {
  final String url;

  const WebViewFinishedLoading({required this.url});

  @override
  List<Object?> get props => [url];
}

/// Event when WebView loading progress changes
class WebViewProgressChanged extends WebViewEvent {
  final double progress;

  const WebViewProgressChanged({required this.progress});

  @override
  List<Object?> get props => [progress];
}

/// Event when WebView URL changes
class WebViewUrlChanged extends WebViewEvent {
  final String url;

  const WebViewUrlChanged({required this.url});

  @override
  List<Object?> get props => [url];
}

/// Event when WebView title changes
class WebViewTitleChanged extends WebViewEvent {
  final String title;

  const WebViewTitleChanged({required this.title});

  @override
  List<Object?> get props => [title];
}

/// Event when WebView navigation state changes
class WebViewNavigationStateChanged extends WebViewEvent {
  final bool canGoBack;
  final bool canGoForward;

  const WebViewNavigationStateChanged({
    required this.canGoBack,
    required this.canGoForward,
  });

  @override
  List<Object?> get props => [canGoBack, canGoForward];
}

/// Event when WebView encounters an error
class WebViewError extends WebViewEvent {
  final String error;

  const WebViewError({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Event to go back in WebView
class WebViewGoBack extends WebViewEvent {
  const WebViewGoBack();
}

/// Event to go forward in WebView
class WebViewGoForward extends WebViewEvent {
  const WebViewGoForward();
}

/// Event to reload WebView
class WebViewReload extends WebViewEvent {
  const WebViewReload();
}

/// Event to clear WebView data
class WebViewClearData extends WebViewEvent {
  const WebViewClearData();
}
