import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/webview_state.dart';
import '../../domain/repositories/webview_repository.dart';
import '../datasources/webview_local_data_source.dart';
import '../models/webview_state_model.dart';

/// Implementation of WebView repository
class WebViewRepositoryImpl implements WebViewRepository {
  final WebViewLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WebViewRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> validateUrl(String url) async {
    try {
      // Basic URL validation
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return const Right(false);
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      // URL is valid and network is available
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'URL validation failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveWebViewState(WebViewState state) async {
    try {
      final stateModel = WebViewStateModel.fromEntity(state);
      await localDataSource.saveWebViewState(stateModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save WebView state: $e'));
    }
  }

  @override
  Future<Either<Failure, WebViewState?>> getLastWebViewState() async {
    try {
      final stateModel = await localDataSource.getLastWebViewState();
      return Right(stateModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get WebView state: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearWebViewData() async {
    try {
      await localDataSource.clearWebViewData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear WebView data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveNavigationHistory(List<String> urls) async {
    try {
      await localDataSource.saveNavigationHistory(urls);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save navigation history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getNavigationHistory() async {
    try {
      final history = await localDataSource.getNavigationHistory();
      return Right(history);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get navigation history: $e'));
    }
  }
}
