import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';
import 'package:number_merge_puzzle/infrastructure/swipe_input_handler.dart';

import 'tile_widget.dart';

/// Widget do tabuleiro de jogo: desenha o grid e captura gestos de swipe.
/// Recebe o board pronto e delega a interpretação do gesto ao SwipeInputHandler,
/// notificando o pai através do callback onSwipe.
class GameBoardWidget extends StatefulWidget {
  final Board board;
  final double size;
  final ValueChanged<Direction> onSwipe;

  const GameBoardWidget({
    super.key,
    required this.board,
    required this.size,
    required this.onSwipe,
  });

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  final _swipeHandler = SwipeInputHandler();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _swipeHandler.onPanStart,
      onPanUpdate: _swipeHandler.onPanUpdate,
      onPanEnd: (details) {
        final direction = _swipeHandler.onPanEnd(details);
        if (direction != null) widget.onSwipe(direction);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.boardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Board.size,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: Board.size * Board.size,
          itemBuilder: (context, index) {
            final row = index ~/ Board.size;
            final col = index % Board.size;
            final value = widget.board.grid[row][col];
            return TileWidget(value: value);
          },
        ),
      ),
    );
  }
}
