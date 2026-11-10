import 'package:flutter/material.dart';

abstract final class AppCardStyles {
  static const major = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(18)),
    border: Border.fromBorderSide(
      BorderSide(color: Color(0xFFF1F5F9), width: 1),
    ),
    boxShadow: [
      BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
    ],
  );

  static const compact = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(
      BorderSide(color: Color(0xFFF1F5F9), width: 1),
    ),
    boxShadow: [
      BoxShadow(color: Color(0x0D0F172A), blurRadius: 14, offset: Offset(0, 4)),
    ],
  );
}
