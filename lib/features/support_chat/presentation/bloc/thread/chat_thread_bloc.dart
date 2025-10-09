import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/support_message.dart';
import '../../../domain/entities/support_thread.dart';
import '../../../domain/usecases/close_thread.dart';
import '../../../domain/usecases/create_or_get_thread.dart';
import '../../../domain/usecases/send_message.dart';
import '../../../domain/usecases/subscribe_messages.dart';

/// Events
abstract class ChatThreadEvent extends Equatable {
  const ChatThreadEvent();
  @override
  List<Object?> get props => [];
}

/// Create (or reuse) the user's active thread, then subscribe to its messages.
class StartThread extends ChatThreadEvent {
  final String? subject;
  const StartThread({this.subject});
  @override
  List<Object?> get props => [subject];
}

/// Subscribe to an existing thread by its id (e.g., when navigated with a known id).
class SubscribeThread extends ChatThreadEvent {
  final String threadId;
  const SubscribeThread(this.threadId);
  @override
  List<Object?> get props => [threadId];
}

/// Send a message within the current thread.
class SendMessageEvent extends ChatThreadEvent {
  final String text;
  final bool asAgent;
  const SendMessageEvent(this.text, {this.asAgent = false});
  @override
  List<Object?> get props => [text, asAgent];
}

/// Close the current thread.
class CloseThreadEvent extends ChatThreadEvent {
  const CloseThreadEvent();
}

/// Internal: messages arrived from the stream.
class _MessagesArrived extends ChatThreadEvent {
  final List<SupportMessage> messages;
  const _MessagesArrived(this.messages);
  @override
  List<Object?> get props => [messages];
}

/// States
abstract class ChatThreadState extends Equatable {
  const ChatThreadState();
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatThreadState {
  const ChatLoading();
}

class ChatReady extends ChatThreadState {
  /// The current thread id (always available in Ready).
  final String threadId;

  /// The full thread object when known (e.g., StartThread path).
  final SupportThread? thread;

  /// Full ordered list of messages.
  final List<SupportMessage> messages;

  const ChatReady({
    required this.threadId,
    this.thread,
    required this.messages,
  });

  ChatReady copyWith({
    String? threadId,
    SupportThread? thread,
    List<SupportMessage>? messages,
  }) {
    return ChatReady(
      threadId: threadId ?? this.threadId,
      thread: thread ?? this.thread,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [threadId, thread, messages];
}

class ChatClosed extends ChatThreadState {
  const ChatClosed();
}

class ChatError extends ChatThreadState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

/// BLoC
class ChatThreadBloc extends Bloc<ChatThreadEvent, ChatThreadState> {
  final CreateOrGetThread _createOrGetThread;
  final SubscribeMessages _subscribeMessages;
  final SendMessage _sendMessage;
  final CloseThread _closeThread;

  StreamSubscription<List<SupportMessage>>? _subscription;

  ChatThreadBloc({
    required CreateOrGetThread createOrGetThread,
    required SubscribeMessages subscribeMessages,
    required SendMessage sendMessage,
    required CloseThread closeThread,
  })  : _createOrGetThread = createOrGetThread,
        _subscribeMessages = subscribeMessages,
        _sendMessage = sendMessage,
        _closeThread = closeThread,
        super(const ChatLoading()) {
    on<StartThread>(_onStartThread);
    on<SubscribeThread>(_onSubscribeThread);
    on<_MessagesArrived>(_onMessagesArrived);
    on<SendMessageEvent>(_onSendMessage);
    on<CloseThreadEvent>(_onCloseThread);
  }

  Future<void> _onStartThread(
      StartThread event,
      Emitter<ChatThreadState> emit,
      ) async {
    emit(const ChatLoading());
    try {
      final thread = await _createOrGetThread(subject: event.subject);
      await _listenToThread(thread.id);
      // Emit Ready with empty list first; the stream will soon deliver messages.
      emit(ChatReady(threadId: thread.id, thread: thread, messages: const []));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSubscribeThread(
      SubscribeThread event,
      Emitter<ChatThreadState> emit,
      ) async {
    emit(const ChatLoading());
    try {
      await _listenToThread(event.threadId);
      // We may not have full thread details here (repository doesn’t expose get-by-id).
      emit(ChatReady(threadId: event.threadId, thread: null, messages: const []));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _listenToThread(String threadId) async {
    await _subscription?.cancel();
    _subscription = _subscribeMessages(threadId).listen(
          (msgs) => add(_MessagesArrived(msgs)),
      onError: (err) => add(_MessagesArrived(const [])), // simple fallback
    );
  }

  void _onMessagesArrived(
      _MessagesArrived event,
      Emitter<ChatThreadState> emit,
      ) {
    final current = state;
    if (current is ChatReady) {
      emit(current.copyWith(messages: event.messages));
    } else if (current is ChatLoading) {
      // If messages land while loading, move straight to ready without thread object.
      if (event.messages.isNotEmpty) {
        final threadId = event.messages.first.threadId;
        emit(ChatReady(threadId: threadId, thread: null, messages: event.messages));
      }
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatThreadState> emit,
      ) async {
    final current = state;
    if (current is! ChatReady) return;
    try {
      await _sendMessage(
        threadId: current.threadId,
        body: event.text,
        asAgent: event.asAgent,
      );
      // No emit here: the realtime stream will deliver the new message.
    } catch (e) {
      emit(ChatError(e.toString()));
      // Optional: revert back to ready so UI remains usable
      if (current is ChatReady) {
        emit(current);
      }
    }
  }

  Future<void> _onCloseThread(
      CloseThreadEvent event,
      Emitter<ChatThreadState> emit,
      ) async {
    final current = state;
    if (current is! ChatReady) return;
    try {
      await _closeThread(current.threadId);
      await _subscription?.cancel();
      _subscription = null;
      emit(const ChatClosed());
    } catch (e) {
      emit(ChatError(e.toString()));
      // Optional: keep chat usable after error
      emit(current);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
