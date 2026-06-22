import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';

class AppColors {
  AppColors._();
  static const int lightTextMaxTileValue = 8;

  static const Color background = Color(0xFF1E1E24);
  static const Color boardBackground = Color(0xFF111115);
  static const Color emptyTile = Color(0xFF25252B);
  static const Color scoreCardBackground = Color(0xFF25252B);
  static const Color developerCreditText = Colors.white54;
  static const Color titleLightText = Colors.white70;
  static const Color titleStrongText = Colors.white;
  static const double developerCreditTextOpacity = 0.3;

  static const Map<int, Color> tileColors = {
    Board.baseTileValue: Color(0xFF3A363F),
    Board.rareTileValue: Color(0xFF4A4E69),
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
    return value <= lightTextMaxTileValue ? Colors.white70 : Colors.black87;
  }
}
