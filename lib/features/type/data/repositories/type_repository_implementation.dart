// lib/features/type/data/repositories/type_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/type/data/datasources/type_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/repositories/type_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_all_type.dart';

class TypeRepositoryImplementation extends TypeRepository {
  final TypeRemoteDatasource typeRemoteDatasource;

  TypeRepositoryImplementation({required this.typeRemoteDatasource});

  @override
  Future<Either<Failure, List<Type>>> getAllType(int page) async {
    try {
      List<Type> result = await typeRemoteDatasource.getAllType(page);
      return Right(result);
    } catch (e) {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, Type>> getType(String id) async {
    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity()
          .checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw "No Connnection";
      } else {
        Type result = await typeRemoteDatasource.getType(id);
        return Right(result);
      }
    } catch (e) {
      return Left(Failure());
    }
  }
}
