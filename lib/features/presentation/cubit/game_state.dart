import 'package:equatable/equatable.dart';
import '../../application/use_cases/make_move_use_case.dart';
import '../../domain/entities/board.dart';

/// Estado imutável do jogo.
/// Cada jogada gera um NOVO GameState — nunca mutamos o estado anterior.
/// Isso é o que torna o Cubit previsível e fácil de testar.
class GameState extends Equatable {
  final Board board;
  final int score;
  final int highScore;
  final GameStatus status;

  const GameState({
    required this.board,
    required this.score,
    required this.highScore,
    required this.status,
  });

  /// Estado inicial antes de qualquer jogo começar.
  factory GameState.initial() {
    return GameState(
      board: Board.empty(),
      score: 0,
      highScore: 0,
      status: GameStatus.playing,
    );
  }

  /// copyWith facilita criar variações do estado sem repetir todos os campos.
  GameState copyWith({
    Board? board,
    int? score,
    int? highScore,
    GameStatus? status,
  }) {
    return GameState(
      board: board ?? this.board,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
    );
  }

  /// Equatable compara o conteúdo do grid, não a referência do objeto —
  /// importante para o Cubit saber quando realmente notificar a UI.
  @override
  List<Object?> get props => [
    board.grid.map((row) => row.join(',')).join('|'),
    score,
    highScore,
    status,
  ];
}
