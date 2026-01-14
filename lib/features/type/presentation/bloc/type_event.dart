// lib/features/type/presentation/bloc/type_event.dart

part of 'type_bloc.dart';

abstract class TypeEvent extends Equatable {
  const TypeEvent();

  @override
  List<Object> get props => [];
}

class TypeEventGetAllTypes extends TypeEvent {
  final int page;

  const TypeEventGetAllTypes(this.page);

  @override
  List<Object> get props => [];
}

class TypeEventGetDetailType extends TypeEvent {
  final String typeId;

  const TypeEventGetDetailType(this.typeId);

  @override
  List<Object> get props => [typeId];
}
