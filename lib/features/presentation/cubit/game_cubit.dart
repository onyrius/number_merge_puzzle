import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/start_new_game_use_case.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

import 'game_state.dart';

/// Cubit responsável pelo estado do jogo.
/// Mesma responsabilidade do antigo GameController (ChangeNotifier),
/// mas seguindo o padrão Cubit: cada ação emite um novo estado imutável
/// através de `emit`, em vez de mutar campos e chamar notifyListeners().
///
/// Não tem NENHUMA regra de jogo aqui — só orquestra os use cases
/// (camada de application) e empacota o resultado em um GameState.
class GameCubit extends Cubit<GameState> {
  final StartNewGameUseCase _startNewGame;
  final MakeMoveUseCase _makeMove;

  GameCubit({required this._startNewGame, required this._makeMove})
    : super(GameState.initial()) {
    resetGame();
  }

  void resetGame() {
    final board = _startNewGame();
    emit(state.copyWith(board: board, score: 0, status: GameStatus.playing));
  }

  void handleMove(Direction direction) {
    // Ignora jogadas depois que o jogo já terminou (vitória ou derrota).
    if (state.status != GameStatus.playing) return;

    final result = _makeMove(state.board, direction);
    if (!result.moved) return;

    final newScore = state.score + result.scoreGained;
    final newHighScore = newScore > state.highScore
        ? newScore
        : state.highScore;

    emit(
      state.copyWith(
        board: result.board,
        score: newScore,
        highScore: newHighScore,
        status: result.status,
      ),
    );
  }
}
