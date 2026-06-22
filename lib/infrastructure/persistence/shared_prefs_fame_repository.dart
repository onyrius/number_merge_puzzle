import 'dart:convert';
import 'package:number_merge_puzzle/features/domain/repositores/game_repository.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/saved_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/domain/entities/board.dart';

/// Implementação concreta do GameRepository usando shared_preferences.
/// Serializa o tabuleiro como uma string JSON simples para armazenar
/// em uma chave-valor (limitação do shared_preferences: só tipos primitivos).
class SharedPrefsGameRepository implements GameRepository {
  static const _boardKey = 'number_merge_puzzle.board';
  static const _scoreKey = 'number_merge_puzzle.score';
  static const _highScoreKey = 'number_merge_puzzle.high_score';

  @override
  Future<void> saveGame(SavedGame savedGame) async {
    final prefs = await SharedPreferences.getInstance();
    final boardJson = jsonEncode(savedGame.board.grid);

    await prefs.setString(_boardKey, boardJson);
    await prefs.setInt(_scoreKey, savedGame.score);
    await prefs.setInt(_highScoreKey, savedGame.highScore);
  }

  @override
  Future<SavedGame?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final boardJson = prefs.getString(_boardKey);

    if (boardJson == null) return null;

    try {
      final decoded = jsonDecode(boardJson) as List<dynamic>;
      final grid = decoded
          .map((row) => (row as List<dynamic>).cast<int>())
          .toList();

      final score = prefs.getInt(_scoreKey) ?? 0;
      final highScore = prefs.getInt(_highScoreKey) ?? 0;

      return SavedGame(board: Board(grid), score: score, highScore: highScore);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_boardKey);
    await prefs.remove(_scoreKey);
    // highScore NÃO é removido de propósito — recorde é permanente.
  }
}
