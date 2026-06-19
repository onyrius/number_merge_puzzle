import 'package:flutter/foundation.dart';
import '../../application/use_cases/make_move_use_case.dart';
import '../../application/use_cases/start_new_game_use_case.dart';
import '../../domain/entities/board.dart';
import '../../domain/value_objects/direction.dart';

/// Controller da tela de jogo.
/// É a ponte entre a UI (widgets) e a camada de aplicação (use cases).
/// Não contém regra de jogo nenhuma — só orquestra chamadas e guarda estado de UI.
class GameController extends ChangeNotifier {
  final StartNewGameUseCase _startNewGame;
  final MakeMoveUseCase _makeMove;

  GameController({required this._startNewGame, required this._makeMove}) {
    resetGame();
  }

  late Board board;
  int score = 0;
  int highScore = 0;
  GameStatus status = GameStatus.playing;

  void resetGame() {
    board = _startNewGame();
    score = 0;
    status = GameStatus.playing;
    notifyListeners();
  }

  void handleMove(Direction direction) {
    // Ignora jogadas depois que o jogo já terminou.
    if (status != GameStatus.playing) return;

    final result = _makeMove(board, direction);
    if (!result.moved) return;

    board = result.board;
    score += result.scoreGained;
    if (score > highScore) highScore = score;
    status = result.status;

    notifyListeners();
  }
}
