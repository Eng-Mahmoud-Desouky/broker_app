import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/webview_state.dart';
import '../repositories/webview_repository.dart';

/// Use case for saving WebView state
class SaveWebViewState implements UseCase<void, SaveWebViewStateParams> {
  final WebViewRepository repository;

  SaveWebViewState(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveWebViewStateParams params) async {
    return await repository.saveWebViewState(params.state);
  }
}

class SaveWebViewStateParams {
  final WebViewState state;

  SaveWebViewStateParams({required this.state});
}
