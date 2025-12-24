import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsAsRead {
  final NotificationsRepository repository;

  MarkAllNotificationsAsRead(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markAllAsRead();
  }
}
