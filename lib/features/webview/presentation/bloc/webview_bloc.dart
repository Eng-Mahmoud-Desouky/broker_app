import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/webview_state.dart' as domain;
import '../../domain/usecases/get_platform_url.dart';
import '../../domain/usecases/save_webview_state.dart';
import '../../domain/usecases/validate_url.dart';
import 'webview_event.dart';
import 'webview_state.dart';

/// BLoC for managing WebView state and events
class WebViewBloc extends Bloc<WebViewEvent, WebViewBlocState> {
  final ValidateUrl validateUrl;
  final SaveWebViewState saveWebViewState;
  final GetPlatformUrl getPlatformUrl;

  // Current WebView state tracking
  String _currentUrl = '';
  String _currentTitle = '';
  bool _canGoBack = false;
  bool _canGoForward = false;
  double _currentProgress = 0.0;

  WebViewBloc({
    required this.validateUrl,
    required this.saveWebViewState,
    required this.getPlatformUrl,
  }) : super(const WebViewInitial()) {
    on<WebViewLoadUrl>(_onLoadUrl);
    on<WebViewStartedLoading>(_onStartedLoading);
    on<WebViewFinishedLoading>(_onFinishedLoading);
    on<WebViewProgressChanged>(_onProgressChanged);
    on<WebViewUrlChanged>(_onUrlChanged);
    on<WebViewTitleChanged>(_onTitleChanged);
    on<WebViewNavigationStateChanged>(_onNavigationStateChanged);
    on<WebViewError>(_onError);
    on<WebViewGoBack>(_onGoBack);
    on<WebViewGoForward>(_onGoForward);
    on<WebViewReload>(_onReload);
    on<WebViewClearData>(_onClearData);
  }

  Future<void> _onLoadUrl(WebViewLoadUrl event, Emitter<WebViewBlocState> emit) async {
    emit(WebViewLoading(url: event.url));

    // Validate URL before loading
    final result = await validateUrl(ValidateUrlParams(url: event.url));
    
    result.fold(
      (failure) => emit(WebViewErrorState(message: failure.message, url: event.url)),
      (isValid) {
        if (!isValid) {
          emit(const WebViewErrorState(message: 'Invalid URL format'));
        } else {
          _currentUrl = event.url;
          _currentProgress = 0.0;
          // The actual loading will be handled by WebView callbacks
        }
      },
    );
  }

  void _onStartedLoading(WebViewStartedLoading event, Emitter<WebViewBlocState> emit) {
    _currentUrl = event.url;
    _currentProgress = 0.0;
    emit(WebViewLoading(url: event.url, progress: _currentProgress));
  }

  void _onFinishedLoading(WebViewFinishedLoading event, Emitter<WebViewBlocState> emit) {
    _currentUrl = event.url;
    _currentProgress = 1.0;
    
    emit(WebViewLoaded(
      url: _currentUrl,
      title: _currentTitle,
      canGoBack: _canGoBack,
      canGoForward: _canGoForward,
    ));

    // Save the current state
    _saveCurrentState();
  }

  void _onProgressChanged(WebViewProgressChanged event, Emitter<WebViewBlocState> emit) {
    _currentProgress = event.progress;
    
    if (state is WebViewLoading) {
      emit(WebViewLoading(url: _currentUrl, progress: _currentProgress));
    }
  }

  void _onUrlChanged(WebViewUrlChanged event, Emitter<WebViewBlocState> emit) {
    _currentUrl = event.url;
    
    if (state is WebViewLoaded) {
      emit((state as WebViewLoaded).copyWith(url: _currentUrl));
    }
  }

  void _onTitleChanged(WebViewTitleChanged event, Emitter<WebViewBlocState> emit) {
    _currentTitle = event.title;
    
    if (state is WebViewLoaded) {
      emit((state as WebViewLoaded).copyWith(title: _currentTitle));
    }
  }

  void _onNavigationStateChanged(WebViewNavigationStateChanged event, Emitter<WebViewBlocState> emit) {
    _canGoBack = event.canGoBack;
    _canGoForward = event.canGoForward;
    
    if (state is WebViewLoaded) {
      emit((state as WebViewLoaded).copyWith(
        canGoBack: _canGoBack,
        canGoForward: _canGoForward,
      ));
    }
  }

  void _onError(WebViewError event, Emitter<WebViewBlocState> emit) {
    emit(WebViewErrorState(message: event.error, url: _currentUrl));
  }

  void _onGoBack(WebViewGoBack event, Emitter<WebViewBlocState> emit) {
    if (_canGoBack) {
      emit(WebViewNavigating(currentUrl: _currentUrl, isGoingBack: true));
      // The actual navigation will be handled by the WebView widget
    }
  }

  void _onGoForward(WebViewGoForward event, Emitter<WebViewBlocState> emit) {
    if (_canGoForward) {
      emit(WebViewNavigating(currentUrl: _currentUrl, isGoingBack: false));
      // The actual navigation will be handled by the WebView widget
    }
  }

  void _onReload(WebViewReload event, Emitter<WebViewBlocState> emit) {
    emit(WebViewLoading(url: _currentUrl, progress: 0.0));
    // The actual reload will be handled by the WebView widget
  }

  void _onClearData(WebViewClearData event, Emitter<WebViewBlocState> emit) {
    emit(const WebViewClearingData());
    // The actual data clearing will be handled by the WebView widget
    // After clearing, emit WebViewDataCleared
  }

  /// Save the current WebView state
  Future<void> _saveCurrentState() async {
    final state = domain.WebViewState(
      url: _currentUrl,
      title: _currentTitle,
      isLoading: false,
      progress: _currentProgress,
      canGoBack: _canGoBack,
      canGoForward: _canGoForward,
    );

    await saveWebViewState(SaveWebViewStateParams(state: state));
  }

  /// Get current URL
  String get currentUrl => _currentUrl;

  /// Get current title
  String get currentTitle => _currentTitle;

  /// Check if can go back
  bool get canGoBack => _canGoBack;

  /// Check if can go forward
  bool get canGoForward => _canGoForward;
}
