// lib/features/category/domain/usecases/get_category.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/repository/banner_repository.dart';

class GetBanner {
  final BannerRepository bannerRepository;
  const GetBanner(this.bannerRepository);

  Future<Either<Failure, BannerSlider>> execute(String id) {
    return bannerRepository.getBanner(id);
  }
}
