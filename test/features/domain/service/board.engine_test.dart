import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

// Substitua pelos caminhos corretos do seu projeto:

// Criamos um Mock para a classe Random do dart:math
class MockRandom extends Mock implements Random {}

void main() {
  late BoardEngine boardEngine;
  late MockRandom mockRandom;

  setUp(() {
    mockRandom = MockRandom();
    // Injetamos o mock do Random no motor do jogo
    boardEngine = BoardEngine(random: mockRandom);
  });

  group('BoardEngine - Movimentação Básica e Fusões', () {
    test('Deve fundir blocos iguais para a ESQUERDA e somar pontuação', () {
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
    });

    test(
      'Deve mover blocos para a DIREITA aplicando as fusões corretamente',
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

    test('Deve mover blocos para CIMA aplicando as fusões verticalmente', () {
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

    test(
      'Deve retornar moved = false se o movimento não alterar o tabuleiro',
      () {
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
      },
    );
  });

  group('BoardEngine - spawnRandomTile (Aleatoriedade Controlada)', () {
    test(
      'Deve spawnar o número 2 (90% de chance) na primeira célula vazia disponível',
      () {
        final inputBoard = Board([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 0], // Apenas a última célula (posição 3,3) está vazia
        ]);

        // Mockando o Random:
        // Como só há 1 célula vazia, empty.length será 1. random.nextInt(1) retorna 0.
        when(() => mockRandom.nextInt(1)).thenReturn(0);
        // nextDouble() < 0.9 gera o número 2. Forçamos retornar 0.5 (menor que 0.9).
        when(() => mockRandom.nextDouble()).thenReturn(0.5);

        final newBoard = boardEngine.spawnRandomTile(inputBoard);

        expect(newBoard.grid[3][3], 2);
      },
    );

    test('Deve spawnar o número 4 (10% de chance)', () {
      final inputBoard = Board([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 0],
      ]);

      when(() => mockRandom.nextInt(1)).thenReturn(0);
      // Forçamos retornar 0.95 (maior que 0.9), gerando o número 4.
      when(() => mockRandom.nextDouble()).thenReturn(0.95);

      final newBoard = boardEngine.spawnRandomTile(inputBoard);

      expect(newBoard.grid[3][3], 4);
    });

    test('Não deve alterar o tabuleiro se não houver células vazias', () {
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

  group('BoardEngine - Condições de Fim e Vitória', () {
    test(
      'isGameOver deve retornar true se o tabuleiro estiver cheio e sem fusões possíveis',
      () {
        final deadBoard = Board([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 2],
        ]);

        // Mockando as propriedades que a sua Engine consome da entidade Board
        // Nota: Certifique-se de que Board implementa ou expõe hasEmptyCell e hasAdjacentEqualCells corretamente.
        expect(boardEngine.isGameOver(deadBoard), true);
      },
    );

    test(
      'isGameOver deve retornar false se houver alguma fusão adjacente disponível',
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

    test('hasWon deve retornar true se o valor de vitória for alcançado', () {
      final winningBoard = Board([
        [2, 0, 0, 0],
        [0, 2048, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      expect(boardEngine.hasWon(winningBoard), true);
    });
  });
  test(
    'Should shift all pieces down without any merges when columns have no matching adjacent pairs',
    () {
      final inputBoard = Board([
        [4, 8, 2, 8],
        [16, 2, 4, 2],
        [4, 8, 16, 32],
        [0, 0, 0, 0], // Only the last row is free
      ]);

      final result = boardEngine.move(inputBoard, Direction.down);

      final expectedGrid = [
        [0, 0, 0, 0], // Top row becomes completely empty
        [4, 8, 2, 8], // Row 0 shifted down to Row 1
        [16, 2, 4, 2], // Row 1 shifted down to Row 2
        [4, 8, 16, 32], // Row 2 shifted down to Row 3 (the bottom row)
      ];

      expect(result.board.grid, expectedGrid);
      expect(result.scoreGained, 0); // No merges occurred
      expect(
        result.moved,
        true,
      ); // True, because pieces actually changed positions
    },
  );
}
