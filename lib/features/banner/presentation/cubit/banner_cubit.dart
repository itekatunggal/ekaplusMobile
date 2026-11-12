import 'package:ekaplus_ekatunggal/features/banner/domain/usecases/get_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/usecases/get_all_banner.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final GetAllBanner getAllBanner;
  final GetBanner getBanner;

  BannerCubit({required this.getAllBanner, required this.getBanner})
    : super(BannerInitial());

  Future<void> fetchBanners({int page = 1}) async {
    emit(BannerLoading());

    final result = await getAllBanner.execute(page);

    result.fold((failure) {
      emit(BannerError(failure.message ?? 'Gagal memuat banner'));
    }, (banners) => emit(BannerLoaded(banners)));
  }

  void reset() {
    emit(BannerInitial());
  }
}
