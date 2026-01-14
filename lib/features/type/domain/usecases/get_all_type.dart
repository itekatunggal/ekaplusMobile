// lib/features/type/domain/usecases/get_all_type.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/repositories/type_repository.dart';

class GetAllType {
  final TypeRepository typeRepository;
  const GetAllType(this.typeRepository);

  Future<Either<Failure, List<Type>>> execute(int page) {
    return typeRepository.getAllType(page);
  }
}
