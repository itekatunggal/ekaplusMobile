// lib/features/category/domain/usecases/get_all_category.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';

class GetAllCategory {
  final CategoryRepository categoryRepository;
  const GetAllCategory(this.categoryRepository);

  Future<Either<Failure, List<Category>>> execute(int page) {
    return categoryRepository.getAllCategory(page);
  }
}
