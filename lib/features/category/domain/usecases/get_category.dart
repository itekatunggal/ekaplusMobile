// lib/features/category/domain/usecases/get_category.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';

class GetCategory {
  final CategoryRepository categoryRepository;
  const GetCategory(this.categoryRepository);

  Future<Either<Failure, Category>> execute(String id) {
    return categoryRepository.getCategory(id);
  }
}
