import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';
import 'package:number_merge_puzzle/features/core/app_dimensions.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';

/// Widget que renderiza um único tile do tabuleiro.
/// É "burro" de propósito: só recebe um valor e desenha. Não sabe de jogo.
class TileWidget extends StatelessWidget {
  final int value;

  const TileWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == Board.emptyCellValue;

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: AppDimensions.tileAnimationMilliseconds,
      ),
      decoration: BoxDecoration(
        color: isEmpty ? AppColors.emptyTile : AppColors.tileColorFor(value),
        borderRadius: BorderRadius.circular(AppDimensions.tileRadius),
      ),
      child: Center(
        child: Text(
          isEmpty ? '' : '$value',
          style: TextStyle(
            fontSize: value > AppDimensions.compactTileFontThreshold
                ? AppDimensions.compactTileFontSize
                : AppDimensions.tileFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorFor(value),
          ),
        ),
      ),
    );
  }
}
