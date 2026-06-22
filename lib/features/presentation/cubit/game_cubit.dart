import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/use_cases/load_game_use_case.dart';
import '../../application/use_cases/make_move_use_case.dart';
import '../../application/use_cases/save_game_use_case.dart';
import '../../application/use_cases/start_new_game_use_case.dart';
import '../../domain/value_objects/direction.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final StartNewGameUseCase _startNewGame;
  final MakeMoveUseCase _makeMove;
  final SaveGameUseCase _saveGame;
  final LoadGameUseCase _loadGame;

  GameCubit({
    required StartNewGameUseCase startNewGame,
    required MakeMoveUseCase makeMove,
    required SaveGameUseCase saveGame,
    required LoadGameUseCase loadGame,
  }) : _startNewGame = startNewGame,
       _makeMove = makeMove,
       _saveGame = saveGame,
       _loadGame = loadGame,
       super(GameState.initial()) {
    _loadGameOrStartNew();
  }

  Future<void> _loadGameOrStartNew() async {
    final savedGame = await _loadGame();

    if (savedGame == null) {
      final board = _startNewGame();
      emit(
        state.copyWith(
          board: board,
          score: 0,
          highScore: 0,
          status: GameStatus.playing,
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        board: savedGame.board,
        score: savedGame.score,
        highScore: savedGame.highScore,
        status: GameStatus.playing,
        isLoading: false,
      ),
    );
  }

  void resetGame() {
    final board = _startNewGame();
    final newState = state.copyWith(
      board: board,
      score: 0,
      status: GameStatus.playing,
      isLoading: false,
    );
    emit(newState);
    _persist(newState);
  }

  void handleMove(Direction direction) {
    if (state.status != GameStatus.playing || state.isLoading) return;

    final result = _makeMove(state.board, direction);

    if (!result.moved && result.status == state.status) return;

    final newScore = state.score + result.scoreGained;
    final newHighScore = newScore > state.highScore
        ? newScore
        : state.highScore;

    final newState = state.copyWith(
      board: result.board,
      score: newScore,
      highScore: newHighScore,
      status: result.status,
    );

    emit(newState);
    _persist(newState);
  }

  Future<void> _persist(GameState gameState) {
    return _saveGame(
      board: gameState.board,
      score: gameState.score,
      highScore: gameState.highScore,
    );
  }
}
