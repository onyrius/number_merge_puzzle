import '../value_objects/tile_position.dart';

/// Entidade que representa o tabuleiro do jogo.
/// Guarda apenas o estado (a matriz) e regras simples sobre esse estado.
/// Não sabe nada sobre Flutter, UI, gestos ou teclado.
/// Seguindo o DDD, é uma entidade do domínio: tem identidade própria (a matriz) e regras de negócio (movimentos, merges, etc).
class Board {
  static const int size = 4;
  static const int emptyCellValue = 0;
  static const int baseTileValue = 2;
  static const int rareTileValue = 4;
  static const int defaultWinValue = 2048;

  /// Matriz size x size. board[row][col].
  final List<List<int>> grid;

  Board(this.grid);

  /// Cria um tabuleiro vazio (todas as células em 0).
  factory Board.empty() {
    return Board(
      List.generate(size, (_) => List.generate(size, (_) => emptyCellValue)),
    );
  }

  /// Cria uma cópia profunda do tabuleiro (importante para imutabilidade).
  Board copy() {
    return Board(grid.map((row) => List<int>.from(row)).toList());
  }

  int valueAt(TilePosition pos) => grid[pos.row][pos.col];

  void setValueAt(TilePosition pos, int value) {
    grid[pos.row][pos.col] = value;
  }

  bool get hasEmptyCell => grid.any((row) => row.contains(emptyCellValue));

  List<TilePosition> get emptyCells {
    final List<TilePosition> cells = [];
    for (int rowIndex = 0; rowIndex < size; rowIndex++) {
      for (int colIndex = 0; colIndex < size; colIndex++) {
        if (grid[rowIndex][colIndex] == emptyCellValue) {
          cells.add(TilePosition(rowIndex, colIndex));
        }
      }
    }
    return cells;
  }

  /// Verifica se existe algum par de células adjacentes com valor igual
  /// (ou seja, ainda existe um merge possível).
  bool get hasAdjacentEqualCells {
    for (int rowIndex = 0; rowIndex < size; rowIndex++) {
      for (int colIndex = 0; colIndex < size; colIndex++) {
        if (colIndex + 1 < size &&
            grid[rowIndex][colIndex] == grid[rowIndex][colIndex + 1]) {
          return true;
        }
        if (rowIndex + 1 < size &&
            grid[rowIndex][colIndex] == grid[rowIndex + 1][colIndex]) {
          return true;
        }
      }
    }
    return false;
  }

  /// Verifica se contém um valor específico no tabuleiro (útil para verificar se o jogador alcançou um bloco 2048, por exemplo).
  bool containsValue(int value) {
    return grid.any((row) => row.contains(value));
  }
}
