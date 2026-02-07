import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_content.dart';
import '../../domain/usecases/get_app_content.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object?> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentLoaded extends ContentState {
  final AppContent content;

  const ContentLoaded({required this.content});

  @override
  List<Object?> get props => [content];
}

class ContentError extends ContentState {
  final String message;

  const ContentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ContentCubit extends Cubit<ContentState> {
  final GetAppContent getAppContent;

  ContentCubit({required this.getAppContent}) : super(ContentInitial());

  Future<void> loadContent(String key) async {
    emit(ContentLoading());

    final result = await getAppContent(GetAppContentParams(key: key));

    result.fold(
      (failure) => emit(ContentError(message: failure.message)),
      (content) => emit(ContentLoaded(content: content)),
    );
  }
}
