// lib/features/category/domain/repositories/category_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';

abstract class BannerRepository {
  Future<Either<Failure, List<BannerSlider>>> getAllBanner(int page);
  Future<Either<Failure, BannerSlider>> getBanner(String id);
}
