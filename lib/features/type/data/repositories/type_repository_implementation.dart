import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/error/failure_mapper.dart';
import 'package:ekaplus_ekatunggal/features/type/data/datasources/type_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/repositories/type_repository.dart';

class TypeRepositoryImplementation extends TypeRepository {
  final TypeRemoteDatasource typeRemoteDatasource;

  TypeRepositoryImplementation({required this.typeRemoteDatasource});

  @override
  Future<Either<Failure, List<Type>>> getAllType(int page) async {
    try {
      final result = await typeRemoteDatasource.getAllType(page);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat tipe'),
      );
    }
  }

  @override
  Future<Either<Failure, Type>> getType(String id) async {
    try {
      final result = await typeRemoteDatasource.getType(id);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat detail tipe'),
      );
    }
  }
}
