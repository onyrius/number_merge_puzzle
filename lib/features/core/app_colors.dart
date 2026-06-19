import 'package:flutter/material.dart';

/// Centraliza todas as cores do jogo. Evita "magic colors" espalhadas pela UI.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF1E1E24);
  static const Color boardBackground = Color(0xFF111115);
  static const Color emptyTile = Color(0xFF25252B);
  static const Color scoreCardBackground = Color(0xFF25252B);

  static const Map<int, Color> tileColors = {
    2: Color(0xFF3A363F),
    4: Color(0xFF4A4E69),
    8: Color(0xFF9A8C98),
    16: Color(0xFFC9ADA7),
    32: Color(0xFFF2E9E4),
    64: Color(0xFFDDBDF1),
    128: Color(0xFFA0C4FF),
    256: Color(0xFFBDB2FF),
    512: Color(0xFFFFC6FF),
  };

  static const Color tileColorFallback = Color(0xFFFFADAD);

  static Color tileColorFor(int value) {
    return tileColors[value] ?? tileColorFallback;
  }

  static Color textColorFor(int value) {
    return value <= 8 ? Colors.white70 : Colors.black87;
  }
}
