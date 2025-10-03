import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:broker_app/features/webview/presentation/bloc/webview_bloc.dart';
import 'package:broker_app/features/webview/presentation/bloc/webview_state.dart';
import 'package:broker_app/features/webview/presentation/pages/webview_screen.dart';
import 'package:broker_app/features/webview/domain/usecases/validate_url.dart';
import 'package:broker_app/features/webview/domain/usecases/save_webview_state.dart';
import 'package:broker_app/features/webview/domain/usecases/get_platform_url.dart';

import 'webview_screen_test.mocks.dart';

@GenerateMocks([
  ValidateUrl,
  SaveWebViewState,
  GetPlatformUrl,
])
void main() {
  group('WebViewScreen', () {
    late MockValidateUrl mockValidateUrl;
    late MockSaveWebViewState mockSaveWebViewState;
    late MockGetPlatformUrl mockGetPlatformUrl;
    late WebViewBloc webViewBloc;

    setUp(() {
      mockValidateUrl = MockValidateUrl();
      mockSaveWebViewState = MockSaveWebViewState();
      mockGetPlatformUrl = MockGetPlatformUrl();
      
      webViewBloc = WebViewBloc(
        validateUrl: mockValidateUrl,
        saveWebViewState: mockSaveWebViewState,
        getPlatformUrl: mockGetPlatformUrl,
      );
    });

    tearDown(() {
      webViewBloc.close();
    });

    testWidgets('should display WebView screen with correct title', (WidgetTester tester) async {
      // Arrange
      const testUrl = 'https://www.amazon.com';
      const testTitle = 'Amazon';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: webViewBloc,
            child: const WebViewScreen(
              initialUrl: testUrl,
              title: testTitle,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('should display initial state correctly', (WidgetTester tester) async {
      // Arrange
      const testUrl = 'https://www.amazon.com';
      const testTitle = 'Amazon';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: webViewBloc,
            child: const WebViewScreen(
              initialUrl: testUrl,
              title: testTitle,
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
    });
  });
}
