// lib/features/type/domain/repositories/type_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';

abstract class TypeRepository {
  Future<Either<Failure, List<Type>>> getAllType(int page);
  Future<Either<Failure, Type>> getType(String id);
}
