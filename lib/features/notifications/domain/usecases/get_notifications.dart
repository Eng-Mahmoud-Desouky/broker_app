import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications {
  final NotificationsRepository repository;

  GetNotifications(this.repository);

  Future<Either<Failure, List<AppNotification>>> call() async {
    return await repository.getNotifications();
  }
}
