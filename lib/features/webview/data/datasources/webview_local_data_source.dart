import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/webview_state_model.dart';

/// Abstract interface for WebView local data source
abstract class WebViewLocalDataSource {
  /// Saves WebView state to local storage
  Future<void> saveWebViewState(WebViewStateModel state);

  /// Retrieves the last saved WebView state
  Future<WebViewStateModel?> getLastWebViewState();

  /// Clears all WebView data from local storage
  Future<void> clearWebViewData();

  /// Saves navigation history
  Future<void> saveNavigationHistory(List<String> urls);

  /// Retrieves navigation history
  Future<List<String>> getNavigationHistory();
}

/// Implementation of WebView local data source using SharedPreferences
class WebViewLocalDataSourceImpl implements WebViewLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _webViewStateKey = 'webview_state';
  static const String _navigationHistoryKey = 'navigation_history';

  WebViewLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveWebViewState(WebViewStateModel state) async {
    final jsonString = json.encode(state.toJson());
    await sharedPreferences.setString(_webViewStateKey, jsonString);
  }

  @override
  Future<WebViewStateModel?> getLastWebViewState() async {
    final jsonString = sharedPreferences.getString(_webViewStateKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return WebViewStateModel.fromJson(jsonMap);
    } catch (e) {
      // If parsing fails, return null and clear corrupted data
      await sharedPreferences.remove(_webViewStateKey);
      return null;
    }
  }

  @override
  Future<void> clearWebViewData() async {
    await Future.wait([
      sharedPreferences.remove(_webViewStateKey),
      sharedPreferences.remove(_navigationHistoryKey),
    ]);
  }

  @override
  Future<void> saveNavigationHistory(List<String> urls) async {
    final jsonString = json.encode(urls);
    await sharedPreferences.setString(_navigationHistoryKey, jsonString);
  }

  @override
  Future<List<String>> getNavigationHistory() async {
    final jsonString = sharedPreferences.getString(_navigationHistoryKey);
    if (jsonString == null) return [];

    try {
      final urlsList = json.decode(jsonString) as List<dynamic>;
      return urlsList.cast<String>();
    } catch (e) {
      // If parsing fails, return empty list and clear corrupted data
      await sharedPreferences.remove(_navigationHistoryKey);
      return [];
    }
  }
}
