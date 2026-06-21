import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

// Cria um Mock para a classe Random do dart:math
class MockRandom extends Mock implements Random {}

void main() {
  late BoardEngine boardEngine;
  late MockRandom mockRandom;

  setUp(() {
    mockRandom = MockRandom();
    // Injeta o mock do Random no motor do jogo
    boardEngine = BoardEngine(random: mockRandom);
  });

  group('BoardEngine - Basic Movement and Merges', () {
    test(
      'GIVEN a board with mergeable pairs and zeros in rows\n'
      'WHEN move is called with Direction.left\n'
      'THEN it should merge identical adjacent blocks to the left and accumulate the score',
      () {
        final inputBoard = Board([
          [2, 2, 0, 0],
          [4, 0, 4, 0],
          [2, 2, 2, 2],
          [0, 0, 0, 0],
        ]);

        final result = boardEngine.move(inputBoard, Direction.left);

        final expectedGrid = [
          [4, 0, 0, 0], // 2+2 fundiu
          [8, 0, 0, 0], // 4+4 ignorou o zero e fundiu
          [4, 4, 0, 0], // 2+2 e 2+2 fundiram separadamente no mesmo turno
          [0, 0, 0, 0],
        ];

        expect(result.board.grid, expectedGrid);
        expect(
          result.scoreGained,
          4 + 8 + 4 + 4,
        ); // 20 pontos ganhos pelas fusões
        expect(result.moved, true);
      },
    );

    test(
      'GIVEN a board with mergeable pairs in rows\n'
      'WHEN move is called with Direction.right\n'
      'THEN it should move blocks to the right applying merges correctly',
      () {
        final inputBoard = Board([
          [2, 2, 0, 0],
          [0, 4, 0, 4],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        final result = boardEngine.move(inputBoard, Direction.right);

        final expectedGrid = [
          [0, 0, 0, 4],
          [0, 0, 0, 8],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ];

        expect(result.board.grid, expectedGrid);
        expect(result.moved, true);
      },
    );

    test('GIVEN a board with a mergeable vertical pair\n'
        'WHEN move is called with Direction.up\n'
        'THEN it should move blocks up and apply the merge vertically', () {
      final inputBoard = Board([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final result = boardEngine.move(inputBoard, Direction.up);

      final expectedGrid = [
        [4, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];

      expect(result.board.grid, expectedGrid);
      expect(result.moved, true);
    });

    test('GIVEN a board that is already compressed in the chosen direction\n'
        'WHEN move is called with Direction.left\n'
        'THEN it should return moved as false and keep the board intact', () {
      final inputBoard = Board([
        [4, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      // Tentar mover para a esquerda quando tudo já está colado na esquerda
      final result = boardEngine.move(inputBoard, Direction.left);

      expect(result.moved, false);
      expect(result.scoreGained, 0);
      expect(result.board.grid, inputBoard.grid);
    });
  });

  group('BoardEngine - spawnRandomTile (Controlled Randomness)', () {
    test('GIVEN a board with empty cells and a random choice favoring the 90% chance\n'
        'WHEN spawnRandomTile is called\n'
        'THEN it should spawn the number 2 in the designated empty cell', () {
      final inputBoard = Board([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 0], // Apenas a última célula (posição 3,3) está vazia
      ]);

      // Mockando o Random:
      // Como só há 1 célula vazia, empty.length será 1. random.nextInt(1) retorna 0.
      when(() => mockRandom.nextInt(1)).thenReturn(0);
      // nextDouble() < 0.9 gera o número 2. Força retornar 0.5 (menor que 0.9).
      when(() => mockRandom.nextDouble()).thenReturn(0.5);

      final newBoard = boardEngine.spawnRandomTile(inputBoard);

      expect(newBoard.grid[3][3], 2);
    });

    test(
      'GIVEN a board with empty cells and a random choice falling into the 10% chance\n'
      'WHEN spawnRandomTile is called\n'
      'THEN it should spawn the number 4 in the designated empty cell',
      () {
        final inputBoard = Board([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 0],
        ]);

        when(() => mockRandom.nextInt(1)).thenReturn(0);
        // Força retornar 0.95 (maior que 0.9), gerando o número 4.
        when(() => mockRandom.nextDouble()).thenReturn(0.95);

        final newBoard = boardEngine.spawnRandomTile(inputBoard);

        expect(newBoard.grid[3][3], 4);
      },
    );

    test('GIVEN a fully populated board with no empty cells\n'
        'WHEN spawnRandomTile is called\n'
        'THEN it should not change or alter the board state', () {
      final fullBoard = Board([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);

      final newBoard = boardEngine.spawnRandomTile(fullBoard);

      expect(newBoard.grid, fullBoard.grid);
    });
  });

  group('BoardEngine - End Conditions and Victory', () {
    test('GIVEN a full board with absolutely no available moves or merges left\n'
        'WHEN isGameOver is checked\n'
        'THEN it should return true', () {
      final deadBoard = Board([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);

      // Mockando as propriedades que a sua Engine consome da entidade Board
      // Nota: Certifique-se de que Board implementa ou expõe hasEmptyCell e hasAdjacentEqualCells corretamente.
      expect(boardEngine.isGameOver(deadBoard), true);
    });

    test(
      'GIVEN a full board that still contains a matching adjacent pair horizontally\n'
      'WHEN isGameOver is checked\n'
      'THEN it should return false',
      () {
        final boardWithMoves = Board([
          [2, 2, 2, 4], // Os dois primeiros podem se fundir horizontalmente
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 2],
        ]);

        expect(boardEngine.isGameOver(boardWithMoves), false);
      },
    );
  });
}
