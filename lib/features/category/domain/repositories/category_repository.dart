// lib/features/category/domain/repositories/category_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/category/data/models/category_group_model.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAllCategory(int page);
  Future<Either<Failure, Category>> getCategory(String id);
  Future<Either<Failure, List<CategoryGroupModel>>> getGroupByType();
}
