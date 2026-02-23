import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
  Future<int> getUnreadCount();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final SupabaseClient supabase;

  NotificationsRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('app_notifications')
        .select()
        .or('user_id.eq.${user.id},is_public.eq.true')
        .order('created_at', ascending: false);

    return (response as List)
        .map((n) => AppNotificationModel.fromJson(n))
        .toList();
  }

  @override
  Future<void> markAllAsRead() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('app_notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  }

  @override
  Future<void> markAsRead(String id) async {
    await supabase
        .from('app_notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  @override
  Future<int> getUnreadCount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 0;

    final response = await supabase
        .from('app_notifications')
        .select('id')
        .or('user_id.eq.${user.id},is_public.eq.true')
        .eq('is_read', false);

    return (response as List).length;
  }
}
