import 'package:equatable/equatable.dart';
import '../../application/use_cases/make_move_use_case.dart';
import '../../domain/entities/board.dart';
import '../../domain/value_objects/game_score.dart';

class GameState extends Equatable {
  final Board board;
  final int score;
  final int highScore;
  final GameStatus status;
  final bool isLoading;

  const GameState({
    required this.board,
    required this.score,
    required this.highScore,
    required this.status,
    this.isLoading = false,
  });

  /// isLoading começa true porque o Cubit ainda vai tentar carregar
  /// um save existente antes de decidir se começa um jogo novo.
  factory GameState.initial() {
    return GameState(
      board: Board.empty(),
      score: GameScore.initial,
      highScore: GameScore.initial,
      status: GameStatus.playing,
      isLoading: true,
    );
  }

  GameState copyWith({
    Board? board,
    int? score,
    int? highScore,
    GameStatus? status,
    bool? isLoading,
  }) {
    return GameState(
      board: board ?? this.board,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    board.grid.map((row) => row.join(',')).join('|'),
    score,
    highScore,
    status,
    isLoading,
  ];
}
