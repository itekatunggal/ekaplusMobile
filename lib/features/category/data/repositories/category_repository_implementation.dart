import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/error/failure_mapper.dart';
import 'package:ekaplus_ekatunggal/features/category/data/datasources/category_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/category/data/models/category_group_model.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImplementation extends CategoryRepository {
  final CategoryRemoteDatasource categoryRemoteDatasource;

  CategoryRepositoryImplementation({required this.categoryRemoteDatasource});

  @override
  Future<Either<Failure, List<Category>>> getAllCategory(int page) async {
    try {
      final result = await categoryRemoteDatasource.getAllCategory(page);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat kategori'),
      );
    }
  }

  @override
  Future<Either<Failure, Category>> getCategory(String id) async {
    try {
      final result = await categoryRemoteDatasource.getCategory(id);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(
          e,
          fallbackMessage: 'Gagal memuat detail kategori',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<CategoryGroupModel>>> getGroupByType() async {
    try {
      final result = await categoryRemoteDatasource.getGroupByType();
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(
          e,
          fallbackMessage: 'Gagal memuat kategori berdasarkan tipe',
        ),
      );
    }
  }
}
