import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/usecases/get_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/usecases/get_all_banner.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final GetAllBanner getAllBanner;
  final GetBanner getBanner;

  BannerCubit({required this.getAllBanner, required this.getBanner})
    : super(BannerInitial());

  bool _isNetworkError(Failure failure) {
    return failure is NetworkFailure ||
        failure is TimeoutFailure ||
        (failure is ServerFailure &&
            (failure.statusCode == null || failure.statusCode! >= 500));
  }

  Future<void> fetchBanners({int page = 1}) async {
    emit(BannerLoading());

    final result = await getAllBanner.execute(page);

    result.fold((failure) {
      // If network failure, keep showing loading (dialog will handle notification)
      if (_isNetworkError(failure)) {
        emit(BannerLoading());
      } else {
        emit(BannerError(failure.message ?? 'Failed to load banners'));
      }
    }, (banners) => emit(BannerLoaded(banners)));
  }

  void reset() {
    emit(BannerInitial());
  }
}
