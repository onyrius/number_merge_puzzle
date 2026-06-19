import 'direction.dart';

class GameBoardEntity {
  static const int defaultGridSize = 4;

  final List<List<int>> matrix;
  final int score;
  final int gridSize;
  final bool isGameOver;

  const GameBoardEntity({
    required this.matrix,
    required this.score,
    required this.gridSize,
    this.isGameOver = false,
  });

  factory GameBoardEntity.empty({int size = defaultGridSize}) {
    return GameBoardEntity(
      matrix: List.generate(size, (_) => List.generate(size, (_) => 0)),
      score: 0,
      isGameOver: false,
      gridSize: size,
    );
  }

  GameBoardEntity copyWith({
    List<List<int>>? matrix,
    int? score,
    int? gridSize,
    bool? isGameOver,
  }) {
    return GameBoardEntity(
      matrix: matrix ?? this.matrix,
      score: score ?? this.score,
      gridSize: gridSize ?? this.gridSize,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }

  // 3. O roteador de movimentos
  GameBoardEntity move(Direction direction) {
    switch (direction) {
      case Direction.left:
        return _moveLeft();
      case Direction.right:
        return _moveRight();
      case Direction.up:
        return _moveUp();
      case Direction.down:
        return _moveDown();
    }
  }

  // 4. O motor matemático purificado (Esquerda)
  GameBoardEntity _moveLeft() {
    List<List<int>> newMatrix = [];
    int pointsGained = 0;

    for (var row in matrix) {
      // Etapa 1: Remover os zeros (Compactar)
      var compressed = row.where((tile) => tile != 0).toList();

      // Etapa 2: Fundir vizinhos iguais
      List<int> merged = [];
      for (int i = 0; i < compressed.length; i++) {
        if (i < compressed.length - 1 && compressed[i] == compressed[i + 1]) {
          int newValue = compressed[i] * 2;
          merged.add(newValue);
          pointsGained += newValue;
          i++; // Pula o vizinho fundido
        } else {
          merged.add(compressed[i]);
        }
      }

      // Etapa 3: Preencher com zeros até o tamanho da grade
      while (merged.length < gridSize) {
        merged.add(0);
      }
      newMatrix.add(merged);
    }

    return copyWith(matrix: newMatrix, score: score + pointsGained);
  }

  // Métodos auxiliares de matriz adaptados para o gridSize
  List<List<int>> _reverse(List<List<int>> matrix) =>
      matrix.map((row) => row.reversed.toList()).toList();

  List<List<int>> _transpose(List<List<int>> matrix) {
    return List.generate(
      gridSize,
      (col) => List.generate(gridSize, (row) => matrix[row][col]),
    );
  }

  // 5. Truques geométricos para as outras direções
  GameBoardEntity _moveRight() {
    var reversedMatrix = _reverse(matrix);
    var moved = GameBoardEntity(
      matrix: reversedMatrix,
      score: score,
      gridSize: gridSize,
    )._moveLeft();
    return copyWith(matrix: _reverse(moved.matrix), score: moved.score);
  }

  GameBoardEntity _moveUp() {
    var transposed = _transpose(matrix);
    var moved = GameBoardEntity(
      matrix: transposed,
      score: score,
      gridSize: gridSize,
    )._moveLeft();
    return copyWith(matrix: _transpose(moved.matrix), score: moved.score);
  }

  GameBoardEntity _moveDown() {
    var transposed = _transpose(matrix);
    var reversed = _reverse(transposed);
    var moved = GameBoardEntity(
      matrix: reversed,
      score: score,
      gridSize: gridSize,
    )._moveLeft();
    var unReversed = _reverse(moved.matrix);
    return copyWith(matrix: _transpose(unReversed), score: moved.score);
  }
}
