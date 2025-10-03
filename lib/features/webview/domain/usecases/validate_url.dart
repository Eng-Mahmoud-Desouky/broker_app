import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/webview_repository.dart';

/// Use case for validating URLs before loading in WebView
class ValidateUrl implements UseCase<bool, ValidateUrlParams> {
  final WebViewRepository repository;

  ValidateUrl(this.repository);

  @override
  Future<Either<Failure, bool>> call(ValidateUrlParams params) async {
    return await repository.validateUrl(params.url);
  }
}

class ValidateUrlParams {
  final String url;

  ValidateUrlParams({required this.url});
}
