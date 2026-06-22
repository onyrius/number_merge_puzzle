import 'dart:math';
import '../entities/board.dart';
import '../value_objects/direction.dart';
import '../value_objects/game_score.dart';
import '../value_objects/tile_position.dart';

/// Resultado de uma jogada: novo tabuleiro, pontos ganhos e se algo mudou.
class MoveResult {
  final Board board;
  final int scoreGained;
  final bool moved;

  const MoveResult({
    required this.board,
    required this.scoreGained,
    required this.moved,
  });
}

/// Serviço de domínio: contém TODA a lógica do jogo 2048.
/// Não conhece Flutter, widgets, nem nada de UI.
/// Pode ser testado isoladamente com testes unitários simples.
class BoardEngine {
  static const double baseTileSpawnChance = 0.9;

  final Random _random;

  // Injeção opcional de dependência com fallback padrão.
  // Permite usar um Random mockado em testes para controlar a aleatoriedade.
  // Se nenhum Random for fornecido, cria um novo Random padrão.
  // initializer list: : _random = random ?? Random();
  BoardEngine({Random? random}) : _random = random ?? Random();

  /// Move o tabuleiro em uma direção e retorna o resultado.
  /// A lógica de up/down/right reaproveita o moveLeft através de
  /// transposição e inversão da matriz (mesma ideia do código original).
  MoveResult move(Board board, Direction direction) {
    Board transformedBoard = board.copy();

    switch (direction) {
      case Direction.left:
        return _moveLeft(transformedBoard);
      case Direction.right:
        transformedBoard = _reverse(transformedBoard);
        final result = _moveLeft(transformedBoard);
        return MoveResult(
          board: _reverse(result.board),
          scoreGained: result.scoreGained,
          moved: result.moved,
        );
      case Direction.up:
        transformedBoard = _transpose(transformedBoard);
        final result = _moveLeft(transformedBoard);
        return MoveResult(
          board: _transpose(result.board),
          scoreGained: result.scoreGained,
          moved: result.moved,
        );
      case Direction.down:
        transformedBoard = _reverse(_transpose(transformedBoard));
        final result = _moveLeft(transformedBoard);
        return MoveResult(
          board: _transpose(_reverse(result.board)),
          scoreGained: result.scoreGained,
          moved: result.moved,
        );
    }
  }

  /// Regra central do jogo: comprime e funde valores iguais para a esquerda.
  MoveResult _moveLeft(Board board) {
    bool moved = false;
    int scoreGained = GameScore.initial;
    final newGrid = <List<int>>[];

    for (int row = 0; row < Board.size; row++) {
      final originalBoard = board.grid[row];
      final compactBoard = originalBoard
          .where((value) => value != Board.emptyCellValue)
          .toList();
      final merged = <int>[];

      for (int i = 0; i < compactBoard.length; i++) {
        if (i + 1 < compactBoard.length &&
            compactBoard[i] == compactBoard[i + 1]) {
          final value = compactBoard[i] * Board.baseTileValue;
          merged.add(value);
          scoreGained += value;
          i++;
          moved = true;
        } else {
          merged.add(compactBoard[i]);
        }
      }

      while (merged.length < Board.size) {
        merged.add(Board.emptyCellValue);
      }

      if (!_listEquals(merged, originalBoard)) moved = true;
      newGrid.add(merged);
    }

    return MoveResult(
      board: Board(newGrid),
      scoreGained: scoreGained,
      moved: moved,
    );
  }

  Board _reverse(Board board) {
    return Board(board.grid.map((row) => row.reversed.toList()).toList());
  }

  Board _transpose(Board board) {
    final newGrid = List.generate(
      Board.size,
      (_) => List.generate(Board.size, (_) => Board.emptyCellValue),
    );
    for (int row = 0; row < Board.size; row++) {
      for (int col = 0; col < Board.size; col++) {
        newGrid[col][row] = board.grid[row][col];
      }
    }
    return Board(newGrid);
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Sorteia uma posição vazia e insere um novo tile.
  /// Retorna o mesmo board (mutado) — usado pelo use case de spawn.
  Board spawnRandomTile(Board board) {
    final empty = board.emptyCells;
    if (empty.isEmpty) return board;

    final TilePosition pos = empty[_random.nextInt(empty.length)];
    final value = _random.nextDouble() < baseTileSpawnChance
        ? Board.baseTileValue
        : Board.rareTileValue;
    final newBoard = board.copy();
    newBoard.setValueAt(pos, value);
    return newBoard;
  }

  /// Game over: sem células vazias e sem merges possíveis.
  bool isGameOver(Board board) {
    if (board.hasEmptyCell) return false;
    return !board.hasAdjacentEqualCells;
  }

  bool hasWon(Board board, {int winValue = Board.defaultWinValue}) {
    return board.containsValue(winValue);
  }
}
