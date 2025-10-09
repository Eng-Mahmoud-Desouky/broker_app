import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/support_thread.dart';
import '../../../domain/usecases/list_threads.dart';

/// ----------------------
/// EVENTS
/// ----------------------

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();
  @override
  List<Object?> get props => [];
}

/// Load the initial list of threads.
class LoadChatThreads extends ChatListEvent {
  const LoadChatThreads();
}

/// Refresh the list manually (pull-to-refresh).
class RefreshChatThreads extends ChatListEvent {
  const RefreshChatThreads();
}

/// Apply a text search to filter the loaded threads.
class ApplyThreadSearch extends ChatListEvent {
  final String query;
  const ApplyThreadSearch(this.query);
  @override
  List<Object?> get props => [query];
}

/// (Optional) Toggle between viewing as an agent or user.
class ToggleAgentView extends ChatListEvent {
  final bool isAgent;
  const ToggleAgentView(this.isAgent);
  @override
  List<Object?> get props => [isAgent];
}

/// ----------------------
/// STATES
/// ----------------------

abstract class ChatListState extends Equatable {
  const ChatListState();
  @override
  List<Object?> get props => [];
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListLoaded extends ChatListState {
  final List<SupportThread> threads;
  final String searchQuery;

  const ChatListLoaded(this.threads, {this.searchQuery = ''});

  @override
  List<Object?> get props => [threads, searchQuery];
}

class ChatListEmpty extends ChatListState {
  const ChatListEmpty();
}

class ChatListError extends ChatListState {
  final String message;
  const ChatListError(this.message);
  @override
  List<Object?> get props => [message];
}

/// ----------------------
/// BLOC IMPLEMENTATION
/// ----------------------

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ListThreads _listThreads;

  /// When true, agent mode can show all threads.
  bool _isAgent = false;

  ChatListBloc({required ListThreads listThreads})
      : _listThreads = listThreads,
        super(const ChatListLoading()) {
    on<LoadChatThreads>(_onLoadThreads);
    on<RefreshChatThreads>(_onRefreshThreads);
    on<ApplyThreadSearch>(_onApplySearch);
    on<ToggleAgentView>(_onToggleAgent);
  }

  Future<void> _onLoadThreads(
      LoadChatThreads event,
      Emitter<ChatListState> emit,
      ) async {
    emit(const ChatListLoading());
    try {
      final threads = await _listThreads();
      if (threads.isEmpty) {
        emit(const ChatListEmpty());
      } else {
        emit(ChatListLoaded(threads));
      }
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onRefreshThreads(
      RefreshChatThreads event,
      Emitter<ChatListState> emit,
      ) async {
    try {
      final threads = await _listThreads();
      if (threads.isEmpty) {
        emit(const ChatListEmpty());
      } else {
        emit(ChatListLoaded(threads));
      }
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  void _onApplySearch(
      ApplyThreadSearch event,
      Emitter<ChatListState> emit,
      ) {
    final current = state;
    if (current is ChatListLoaded) {
      final q = event.query.toLowerCase().trim();
      if (q.isEmpty) {
        emit(ChatListLoaded(current.threads));
        return;
      }
      final filtered = current.threads.where((t) {
        final subj = t.subject?.toLowerCase() ?? '';
        final stat = t.status.toLowerCase();
        final id = t.id.toLowerCase();
        return subj.contains(q) || stat.contains(q) || id.contains(q);
      }).toList();
      if (filtered.isEmpty) {
        emit(const ChatListEmpty());
      } else {
        emit(ChatListLoaded(filtered, searchQuery: event.query));
      }
    }
  }

  void _onToggleAgent(
      ToggleAgentView event,
      Emitter<ChatListState> emit,
      ) {
    _isAgent = event.isAgent;
    // In the future, you could call a different use case for agent listing here.
  }

  bool get isAgent => _isAgent;
}
