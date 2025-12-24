import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class GetUnreadNotificationsCount {
  final NotificationsRepository repository;

  GetUnreadNotificationsCount(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getUnreadCount();
  }
}
