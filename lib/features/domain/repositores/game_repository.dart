import 'package:number_merge_puzzle/features/domain/value_objects/saved_game.dart';

/// Contrato de persistência do jogo.
/// O domínio define O QUE precisa ser feito (salvar, carregar, limpar),
/// mas não COMO — isso é responsabilidade da camada de infraestrutura.
///
/// Essa abstração é o que permite trocar shared_preferences por Hive,
/// sqflite, ou até um backend remoto, sem tocar em domain/application/presentation.
abstract class GameRepository {
  /// Salva o estado atual da partida. Sobrescreve o save anterior, se houver.
  Future<void> saveGame(SavedGame savedGame);

  /// Carrega a última partida salva, ou null se nunca houve um save
  /// (ex: primeira vez abrindo o app, ou save corrompido).
  Future<SavedGame?> loadGame();

  /// Remove o save da partida em andamento (ex: ao iniciar um jogo novo
  /// explicitamente). O highScore é preservado propositalmente.
  Future<void> clearSavedGame();
}
