import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, int>> getUnreadCount();
}
