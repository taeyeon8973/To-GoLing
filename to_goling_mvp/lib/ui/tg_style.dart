import 'package:flutter/material.dart';

class TG {
  static const bg = Color(0xFFF7F6F2);
  static const ink = Color(0xFF0B0F19);
  static const card = Colors.white;

  // Y2K 포인트
  static const neonBlue = Color(0xFF7AA7FF);
  static const neonPink = Color(0xFFFF7BD8);
  static const neonMint = Color(0xFF7FF5D5);

  static const radiusXL = 28.0;
  static const radiusL = 22.0;

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  static BoxDecoration glassCard({double radius = radiusXL}) => BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: softShadow,
      );

  static LinearGradient y2kGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE9F0FF),
      Color(0xFFFFE8F7),
      Color(0xFFE8FFF7),
    ],
  );
}
