import '../entities/board.dart';

/// Representa o "snapshot" salvo de uma partida: o tabuleiro atual,
/// a pontuação corrente e o recorde. É um Value Object simples,
/// usado para entrar e sair da camada de persistência.
class SavedGame {
  final Board board;
  final int score;
  final int highScore;

  const SavedGame({
    required this.board,
    required this.score,
    required this.highScore,
  });
}
