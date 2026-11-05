// // lib/features/type/presentation/bloc/type_bloc.dart
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/constants.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_all_type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_type.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

part 'type_event.dart';
part 'type_state.dart';

class SubType {
  String name;
  bool status;

  SubType(this.name, this.status);
}

class ResponseSub {
  final List<List<String>> filters;
  final List<SubType> subType;
  ResponseSub(this.filters, this.subType);
}

class TypeBloc extends Bloc<TypeEvent, TypeState> {
  final GetAllType getAllType;
  final GetType getType;
  int selectedImage = 0;

  bool _isNetworkError(Failure failure) {
    return failure is NetworkFailure ||
        failure is TimeoutFailure ||
        (failure is ServerFailure &&
            (failure.statusCode == null || failure.statusCode! >= 500));
  }

  Future<ResponseSub> getSubType(String id) async {
    List<SubType> subType = [SubType(id, true)];
    List<List<String>> filters = [
      ["item_group", "=", id],
    ];
    try {
      String encodedId = Uri.encodeComponent(id);
      Uri uri = Uri.parse(
        "${Constants.apiBaseUrl}/api/public/Item Group/$encodedId",
      );

      var response = await http.Client().get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> dataBody = jsonDecode(response.body);
        List<dynamic> childs = dataBody['childs'];
        if (childs.isNotEmpty) {
          List<SubType> genSub = childs.map((item) {
            return SubType(item["name"], false);
          }).toList();
          subType = [...subType, ...genSub];
          List<List<String>> genFilters = childs.map<List<String>>((item) {
            return ["item_group", "=", item["name"] as String];
          }).toList();

          filters = [...filters, ...genFilters];
        }
      }
      // ignore: empty_catches
    } catch (e) {}
    return ResponseSub(filters, subType);
  }

  TypeBloc({required this.getAllType, required this.getType})
    : super(TypeStateEmpty()) {
    on<TypeEventGetAllTypes>((event, emit) async {
      emit(TypeStateLoading());

      Either<Failure, List<Type>> resultGetAllType = await getAllType.execute(
        event.page,
      );

      resultGetAllType.fold((failure) {
        // If network failure, keep showing shimmer (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(TypeStateLoading());
        } else {
          emit(TypeStateError('Cannot get all Types'));
        }
      }, (r) => emit(TypeStateLoadedAllType(r)));
    });

    on<TypeEventGetDetailType>((event, emit) async {
      emit(TypeStateLoading());

      Either<Failure, Type> typeResult = await getType.execute(event.typeId);

      typeResult.fold(
        (l) => emit(TypeStateError('Cannot get Type details')),
        (r) => emit(TypeStateLoadedType(r)),
      );
    });
  }
}
