import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';

/// Caso de uso: iniciar uma nova partida.
/// Cria um tabuleiro vazio e posiciona os 2 tiles iniciais.
class StartNewGameUseCase {
  final BoardEngine _engine;

  StartNewGameUseCase(this._engine);

  Board call() {
    Board board = Board.empty();
    board = _engine.spawnRandomTile(board);
    board = _engine.spawnRandomTile(board);
    return board;
  }
}
