// lib/features/category/domain/usecases/get_all_category.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';

import 'package:ekaplus_ekatunggal/features/category/domain/entities/category_group.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';

class GetByType {
  final CategoryRepository categoryRepository;

  GetByType(this.categoryRepository);

  Future<Either<Failure, List<CategoryGroupEntity>>> execute() {
    return categoryRepository.getGroupByType();
  }
}
