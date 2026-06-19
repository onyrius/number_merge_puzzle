import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';

/// Widget que renderiza um único tile do tabuleiro.
/// É "burro" de propósito: só recebe um valor e desenha. Não sabe de jogo.
class TileWidget extends StatelessWidget {
  final int value;

  const TileWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: isEmpty ? AppColors.emptyTile : AppColors.tileColorFor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          isEmpty ? '' : '$value',
          style: TextStyle(
            fontSize: value > 100 ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorFor(value),
          ),
        ),
      ),
    );
  }
}
