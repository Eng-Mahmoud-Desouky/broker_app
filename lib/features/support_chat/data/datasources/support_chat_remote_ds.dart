import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/support_message_model.dart';
import '../models/support_thread_model.dart';

/// Remote data source for Support Chat feature (Supabase).
///
/// Assumptions:
/// - Auth is required (RLS uses auth.uid()).
/// - Database objects & RLS are created as in your SQL script:
///   - tables: public.support_threads, public.support_messages
///   - rpc: public.create_or_get_my_thread(subject text default null)
///   - publication: supabase_realtime includes both tables (for streaming)
///
/// Notes:
/// - Realtime: use `.stream(primaryKey: ['id'])` (official Supabase Flutter).
/// - We DO NOT manually bump `last_message_at`; your trigger does it automatically.
/// - All methods throw [PostgrestException] or [AuthException] on failure; let the repository map them to Failures/Either if desired.
class SupportChatRemoteDataSource {
  final SupabaseClient _client;

  SupportChatRemoteDataSource(this._client);

  /// Ensures there is a signed-in user; otherwise throws.
  void _ensureAuthed() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw const AuthException('User must be authenticated to use support chat.');
    }
  }

  /// Create (or fetch) the user's open thread via RPC.
  /// If a non-closed thread exists, it is returned; otherwise a new one is created.
  Future<SupportThreadModel> createOrGetMyThread({String? subject}) async {
    _ensureAuthed();
    final res = await _client
        .rpc('create_or_get_my_thread', params: {'subject': subject})
        .single();

    // Supabase Dart returns dynamic; cast to Map<String, dynamic> safely.
    final map = (res as Map).cast<String, dynamic>();
    return SupportThreadModel.fromMap(map);
  }

  /// Get a specific thread by id (RLS ensures access).
  Future<SupportThreadModel> getThreadById(String threadId) async {
    _ensureAuthed();
    final res = await _client
        .from('support_threads')
        .select('*')
        .eq('id', threadId)
        .single();

    final map = (res as Map).cast<String, dynamic>();
    return SupportThreadModel.fromMap(map);
  }

  /// List current user's threads (most recent first).
  Future<List<SupportThreadModel>> listThreadsForMe({int limit = 50}) async {
    _ensureAuthed();
    final uid = _client.auth.currentUser!.id;

    final data = await _client
        .from('support_threads')
        .select('*')
        .eq('user_id', uid)
        .order('last_message_at', ascending: false)
        .limit(limit);

    return (data as List)
        .cast<Map>()
        .map((m) => SupportThreadModel.fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  /// Subscribe to messages of a thread in realtime (ordered ascending by created_at).
  ///
  /// Emits the current snapshot and any future inserts/updates that pass RLS.
  Stream<List<SupportMessageModel>> subscribeMessages(String threadId) {
    _ensureAuthed();

    // The .stream API automatically emits initial snapshot + updates.
    final stream = _client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('thread_id', threadId)
        .order('created_at', ascending: true)
        .map((rows) => rows
        .cast<Map>()
        .map((r) => SupportMessageModel.fromMap(r.cast<String, dynamic>()))
        .toList());

    return stream;
  }

  /// Send a message in a thread as the **current user**.
  /// In a customer app, `sender` is always 'user'.
  Future<void> sendMessage({
    required String threadId,
    required String body,
  }) async {
    _ensureAuthed();
    final uid = _client.auth.currentUser!.id;

    await _client.from('support_messages').insert({
      'thread_id': threadId,
      'sender_id': uid,
      'sender': 'user', // customer app
      'body': body,
      // attachments: null,
    });

    // last_message_at is bumped by DB trigger (bump_thread_lastmsg).
  }

  /// Close a thread (user can close their own; RLS policy allows it).
  Future<void> closeThread(String threadId) async {
    _ensureAuthed();

    // Force returning row to detect RLS issues early (optional but helpful)
    final updated = await _client
        .from('support_threads')
        .update({'status': 'closed'})
        .eq('id', threadId)
        .select('id');

    // If no rows returned, RLS blocked or wrong id
    if (updated is List && updated.isEmpty) {
      throw PostgrestException(
        message: 'Thread not updated (RLS or invalid id).',
        code: 'PGRST_NOT_UPDATED',
        details: null,
        hint: null,
      );
    }
  }

  // ---------------------------
  // Optional helpers for agents
  // ---------------------------

  /// (Agent) List all threads (most recent first). Requires agent RLS.
  Future<List<SupportThreadModel>> listThreadsForAgent({int limit = 100}) async {
    _ensureAuthed();

    final data = await _client
        .from('support_threads')
        .select('*')
        .order('last_message_at', ascending: false)
        .limit(limit);

    return (data as List)
        .cast<Map>()
        .map((m) => SupportThreadModel.fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  /// (Agent) Send message as agent.
  Future<void> sendAgentMessage({
    required String threadId,
    required String body,
  }) async {
    _ensureAuthed();
    final uid = _client.auth.currentUser!.id;

    await _client.from('support_messages').insert({
      'thread_id': threadId,
      'sender_id': uid,
      'sender': 'agent',
      'body': body,
    });
  }

  /// (Optional) Mark all messages addressed to current user as read.
  /// You can call this when opening the chat from the user side, if you track read state.
  Future<int> markAllAsReadForMe(String threadId) async {
    _ensureAuthed();
    final uid = _client.auth.currentUser!.id;

    // Example: mark messages sent by the other party as read now.
    // Adjust where-clause if you keep per-recipient read receipts.
    final res = await _client
        .from('support_messages')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('thread_id', threadId)
        .neq('sender_id', uid)
        .filter('read_at', 'is', null)
        .select('id');

    if (res is List) return res.length;
    return 0;
  }
}
