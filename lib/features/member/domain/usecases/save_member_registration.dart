// lib/features/member/domain/usecases/save_member_registration.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class SaveMemberRegistration {
  final MemberRepository repository;

  const SaveMemberRegistration(this.repository);

  Future<Either<Failure, MemberRegistration>> execute(
    Map<String, dynamic> registration, {
    required Map<String, File> files,
  }) {
    return repository.saveRegistration(registration, files: files);
  }
}
