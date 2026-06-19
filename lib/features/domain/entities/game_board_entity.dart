class GameBoardEntity {
  final List<List<int>> matrix;
  final int score;
  final bool isGameOver;

  const GameBoardEntity({
    required this.matrix,
    required this.score,
    this.isGameOver = false,
  });

  factory GameBoardEntity.empty() {
    return GameBoardEntity(
      matrix: List.generate(4, (_) => List.generate(4, (_) => 0)),
      score: 0,
      isGameOver: false,
    );
  }

  GameBoardEntity copyWith({
    List<List<int>>? matrix,
    int? score,
    bool? isGameOver,
  }) {
    return GameBoardEntity(
      matrix: matrix ?? this.matrix,
      score: score ?? this.score,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}
