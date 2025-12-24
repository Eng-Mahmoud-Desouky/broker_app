import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_unread_count.dart';
import '../../domain/usecases/mark_all_read.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotifications getNotifications;
  final GetUnreadNotificationsCount getUnreadCount;
  final MarkAllNotificationsAsRead markAllAsRead;

  NotificationsCubit({
    required this.getNotifications,
    required this.getUnreadCount,
    required this.markAllAsRead,
  }) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    final result = await getNotifications();
    final countResult = await getUnreadCount();

    result.fold((failure) => emit(NotificationsError(failure.message)), (
      notifications,
    ) {
      countResult.fold(
        (failure) => emit(
          NotificationsLoaded(notifications: notifications, unreadCount: 0),
        ),
        (count) => emit(
          NotificationsLoaded(notifications: notifications, unreadCount: count),
        ),
      );
    });
  }

  Future<void> refreshUnreadCount() async {
    final countResult = await getUnreadCount();
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      countResult.fold(
        (_) => null,
        (count) => emit(
          NotificationsLoaded(
            notifications: currentState.notifications,
            unreadCount: count,
          ),
        ),
      );
    } else {
      loadNotifications();
    }
  }

  Future<void> markNotificationsAsRead() async {
    await markAllAsRead();
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(
        NotificationsLoaded(
          notifications:
              currentState.notifications
                  .map((n) => n.copyWith(isRead: true))
                  .toList(),
          unreadCount: 0,
        ),
      );
    }
  }
}
