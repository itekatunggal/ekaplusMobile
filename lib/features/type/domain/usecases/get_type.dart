// lib/features/type/domain/usecases/get_type.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/repositories/type_repository.dart';

class GetType {
  final TypeRepository typeRepository;
  const GetType(this.typeRepository);

  Future<Either<Failure, Type>> execute(String id) {
    return typeRepository.getType(id);
  }
}
