import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/repository/banner_repository.dart';

class GetAllBanner {
  final BannerRepository bannerRepository;
  const GetAllBanner(this.bannerRepository);

  Future<Either<Failure, List<BannerSlider>>> execute(int page) {
    return bannerRepository.getAllBanner(page);
  }
}
