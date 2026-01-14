// lib/features/type/presentation/bloc/type_state.dart

part of 'type_bloc.dart';

abstract class TypeState extends Equatable {}

class TypeStateEmpty extends TypeState {
  @override
  List<Object?> get props => [];
}

class TypeStateLoading extends TypeState {
  @override
  List<Object?> get props => [];
}

class TypeStateError extends TypeState {
  final String message;

  TypeStateError(this.message);
  @override
  List<Object?> get props => [message];
}

class TypeStateLoadedAllType extends TypeState {
  final List<Type> allType;

  TypeStateLoadedAllType(this.allType);
  @override
  List<Object?> get props => [allType];
}

class TypeStateLoadedType extends TypeState {
  final Type detailType;

  TypeStateLoadedType(this.detailType);
  @override
  List<Object?> get props => [detailType];
}
