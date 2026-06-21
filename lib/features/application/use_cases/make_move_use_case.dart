import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

/// Status do jogo após uma jogada.
enum GameStatus { playing, won, gameOver }

/// Resultado completo de uma jogada, pronto para a camada de apresentação consumir.
class MakeMoveResult {
  final Board board;
  final int scoreGained;
  final bool moved;
  final GameStatus status;

  const MakeMoveResult({
    required this.board,
    required this.scoreGained,
    required this.moved,
    required this.status,
  });
}

/// Caso de uso: processar uma jogada do jogador.
/// Orquestra o BoardEngine: move, spawna novo tile (se moveu) e checa o status do jogo.
/// Essa é a "regra de aplicação" — o BoardEngine não sabe a ordem dessas etapas,
/// só sabe executar cada uma isoladamente.
/// Está na camada de application porque é a "lógica de orquestração" que conecta as regras de domínio (BoardEngine)
class MakeMoveUseCase {
  final BoardEngine _engine;

  MakeMoveUseCase(this._engine);

  MakeMoveResult call(Board board, Direction direction) {
    final moveResult = _engine.move(board, direction);

    if (!moveResult.moved) {
      final status = _engine.isGameOver(board)
          ? GameStatus.gameOver
          : GameStatus.playing;

      return MakeMoveResult(
        board: board,
        scoreGained: 0,
        moved: false,
        status: status,
      );
    }

    final boardWithNewTile = _engine.spawnRandomTile(moveResult.board);

    GameStatus status = GameStatus.playing;
    if (_engine.hasWon(boardWithNewTile)) {
      status = GameStatus.won;
    } else if (_engine.isGameOver(boardWithNewTile)) {
      status = GameStatus.gameOver;
    }

    return MakeMoveResult(
      board: boardWithNewTile,
      scoreGained: moveResult.scoreGained,
      moved: true,
      status: status,
    );
  }
}
