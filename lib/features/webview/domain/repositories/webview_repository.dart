import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/webview_state.dart';

/// Repository interface for WebView operations
abstract class WebViewRepository {
  /// Validates if a URL is safe and accessible
  Future<Either<Failure, bool>> validateUrl(String url);

  /// Saves the current WebView state for persistence
  Future<Either<Failure, void>> saveWebViewState(WebViewState state);

  /// Retrieves the last saved WebView state
  Future<Either<Failure, WebViewState?>> getLastWebViewState();

  /// Clears all saved WebView data including cookies and cache
  Future<Either<Failure, void>> clearWebViewData();

  /// Saves navigation history
  Future<Either<Failure, void>> saveNavigationHistory(List<String> urls);

  /// Retrieves navigation history
  Future<Either<Failure, List<String>>> getNavigationHistory();
}
