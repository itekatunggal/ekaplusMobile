import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/error/failure_mapper.dart';
import 'package:ekaplus_ekatunggal/features/banner/data/datasources/banner_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/repository/banner_repository.dart';

class BannerRepositoryImplementation extends BannerRepository {
  final BannerRemoteDatasource bannerRemoteDatasource;

  BannerRepositoryImplementation({required this.bannerRemoteDatasource});

  @override
  Future<Either<Failure, List<BannerSlider>>> getAllBanner(int page) async {
    try {
      final result = await bannerRemoteDatasource.getAllBanner(page);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat banner'),
      );
    }
  }

  @override
  Future<Either<Failure, BannerSlider>> getBanner(String id) async {
    try {
      final result = await bannerRemoteDatasource.getBanner(id);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat detail banner'),
      );
    }
  }
}
