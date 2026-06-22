import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/repositores/game_repository.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/saved_game.dart';

/// Caso de uso: persistir o estado atual da partida.
/// Não sabe SE está usando shared_preferences, Hive, ou outra coisa —
/// só conhece o contrato GameRepository.
class SaveGameUseCase {
  final GameRepository _repository;

  SaveGameUseCase(this._repository);

  Future<void> call({
    required Board board,
    required int score,
    required int highScore,
  }) {
    return _repository.saveGame(
      SavedGame(board: board, score: score, highScore: highScore),
    );
  }
}
