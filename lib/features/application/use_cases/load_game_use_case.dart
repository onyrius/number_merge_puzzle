import 'package:number_merge_puzzle/features/domain/repositores/game_repository.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/saved_game.dart';

/// Caso de uso: recuperar a última partida salva ao abrir o app.
/// Retorna null quando não há nada salvo (primeira vez, ou save corrompido) —
/// nesse caso, quem chamar deve iniciar um jogo novo normalmente.
class LoadGameUseCase {
  final GameRepository _repository;

  LoadGameUseCase(this._repository);

  Future<SavedGame?> call() {
    return _repository.loadGame();
  }
}
