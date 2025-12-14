import 'package:equatable/equatable.dart';

/// Base usecase pattern for all usecases
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// No parameters class
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
