import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

/// Random determinístico para testes que dependem de spawnRandomTile.
/// Sempre retorna 0 para nextInt (primeira posição livre) e um valor fixo
/// para nextDouble, tornando o resultado do spawn previsível.
class _FixedRandom implements Random {
  final int intValue;
  final double doubleValue;

  _FixedRandom({this.intValue = 0, this.doubleValue = 0.5});

  @override
  int nextInt(int max) => intValue;

  @override
  double nextDouble() => doubleValue;

  @override
  bool nextBool() => false;

  @override
  Random get secure => this;
}

void main() {
  late BoardEngine engine;

  setUp(() {
    engine = BoardEngine(random: _FixedRandom());
  });

  group('moveLeft (via Direction.left)', () {
    test('compacta valores não-zero para a esquerda sem merge', () {
      final board = Board([
        [0, 2, 0, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final result = engine.move(board, Direction.left);

      expect(result.board.grid[0], [2, 4, 0, 0]);
      expect(result.moved, isTrue);
      expect(result.scoreGained, 0);
    });

    test('funde dois valores iguais adjacentes e soma a pontuação', () {
      final board = Board([
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final result = engine.move(board, Direction.left);

      expect(result.board.grid[0], [4, 0, 0, 0]);
      expect(result.scoreGained, 4);
      expect(result.moved, isTrue);
    });

    test(
      'não funde a mesma célula duas vezes na mesma jogada (regra clássica do 2048)',
      () {
        // [2, 2, 2, 2] deve virar [4, 4, 0, 0], não [8, 0, 0, 0]
        final board = Board([
          [2, 2, 2, 2],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        final result = engine.move(board, Direction.left);

        expect(result.board.grid[0], [4, 4, 0, 0]);
        expect(result.scoreGained, 8);
      },
    );

    test(
      'não reporta movimento quando o tabuleiro já está no estado final',
      () {
        final board = Board([
          [2, 4, 8, 16],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        final result = engine.move(board, Direction.left);

        expect(result.moved, isFalse);
        expect(result.board.grid[0], [2, 4, 8, 16]);
      },
    );
  });

  group('moveRight', () {
    test('compacta valores para a direita', () {
      final board = Board([
        [2, 0, 4, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final result = engine.move(board, Direction.right);

      expect(result.board.grid[0], [0, 0, 2, 4]);
      expect(result.moved, isTrue);
    });

    test('funde valores iguais na ponta direita', () {
      final board = Board([
        [0, 0, 4, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final result = engine.move(board, Direction.right);

      expect(result.board.grid[0], [0, 0, 0, 8]);
      expect(result.scoreGained, 8);
    });
  });

  group('moveUp', () {
    test('compacta valores de uma coluna para cima', () {
      final board = Board([
        [0, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [4, 0, 0, 0],
      ]);

      final result = engine.move(board, Direction.up);

      expect(result.board.grid[0][0], 2);
      expect(result.board.grid[1][0], 4);
      expect(result.board.grid[2][0], 0);
      expect(result.board.grid[3][0], 0);
      expect(result.moved, isTrue);
    });
  });

  group('moveDown — cenário do bug caçado na conversa', () {
    test('tabuleiro quase cheio com 1 linha vazia: move para baixo deve '
        'deslizar as colunas para o fundo (sem merges)', () {
      // Exato cenário relatado: 3 linhas preenchidas, 1 linha vazia no fundo.
      final board = Board([
        [4, 8, 2, 8],
        [16, 2, 4, 2],
        [4, 8, 16, 32],
        [0, 0, 0, 0],
      ]);

      final result = engine.move(board, Direction.down);

      expect(
        result.moved,
        isTrue,
        reason:
            'Há uma linha vazia no fundo; mover para baixo TEM que '
            'produzir uma mudança, mesmo sem nenhum merge possível.',
      );
      expect(result.board.grid, [
        [0, 0, 0, 0],
        [4, 8, 2, 8],
        [16, 2, 4, 2],
        [4, 8, 16, 32],
      ]);
      expect(result.scoreGained, 0);
    });

    test(
      'tabuleiro do segundo print relatado: 1 linha preenchida + 2 tiles soltos',
      () {
        final board = Board([
          [4, 8, 2, 8],
          [0, 16, 64, 4],
          [0, 0, 4, 32],
          [0, 0, 2, 8],
        ]);

        final result = engine.move(board, Direction.down);

        expect(result.moved, isTrue);
        expect(result.board.grid, [
          [0, 0, 2, 8],
          [0, 0, 64, 4],
          [0, 8, 4, 32],
          [4, 16, 2, 8],
        ]);
      },
    );

    test('moveDown não deve produzir o mesmo resultado de moveUp '
        '(regressão do bug de transpose/reverse trocados)', () {
      final board = Board([
        [2, 4, 8, 16],
        [32, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final downResult = engine.move(board, Direction.down);
      final upResult = engine.move(board, Direction.up);

      // Esse é o teste de regressão direto do bug relatado:
      // "apertei para baixo e o tabuleiro se moveu como se fosse para cima".
      expect(downResult.board.grid, isNot(equals(upResult.board.grid)));

      // E confere explicitamente o resultado geométrico correto:
      // tudo deve descer para a última linha, mantendo as colunas.
      expect(downResult.board.grid, [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [2, 0, 0, 0],
        [32, 4, 8, 16],
      ]);

      // moveUp no mesmo tabuleiro não deveria alterar nada
      // (os valores já estão "colados" no topo).
      expect(upResult.moved, isFalse);
    });

    test('funde corretamente quando há merge possível na direção down', () {
      final board = Board([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final result = engine.move(board, Direction.down);

      expect(result.board.grid[3][0], 4);
      expect(result.scoreGained, 4);
      expect(result.moved, isTrue);
    });

    test('down e up são transformações inversas uma da outra (ida e volta)', () {
      // Aplicar down e depois up no resultado de um tabuleiro já "assentado"
      // embaixo deveria trazer os valores de volta para cima sem alterar a ordem.
      final original = Board([
        [2, 4, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      final afterDown = engine.move(original, Direction.down);
      final afterUpAgain = engine.move(afterDown.board, Direction.up);

      expect(afterUpAgain.board.grid[0], [2, 4, 0, 0]);
    });
  });

  group('spawnRandomTile', () {
    test('insere um novo tile em uma célula vazia', () {
      final board = Board.empty();
      final result = engine.spawnRandomTile(board);

      final nonZeroCount = result.grid
          .expand((row) => row)
          .where((v) => v != 0)
          .length;
      expect(nonZeroCount, 1);
    });

    test('não altera o tabuleiro quando não há células vazias', () {
      final fullBoard = Board(
        List.generate(4, (_) => List.generate(4, (_) => 2)),
      );

      final result = engine.spawnRandomTile(fullBoard);

      expect(result.grid, fullBoard.grid);
    });

    test(
      'com _FixedRandom(doubleValue: 0.95), insere o valor 4 (cauda dos 10%)',
      () {
        final engineWithHighRandom = BoardEngine(
          random: _FixedRandom(doubleValue: 0.95),
        );
        final board = Board.empty();

        final result = engineWithHighRandom.spawnRandomTile(board);

        expect(result.grid[0][0], 4);
      },
    );

    test(
      'com _FixedRandom(doubleValue: 0.1), insere o valor 2 (90% de chance)',
      () {
        final engineWithLowRandom = BoardEngine(
          random: _FixedRandom(doubleValue: 0.1),
        );
        final board = Board.empty();

        final result = engineWithLowRandom.spawnRandomTile(board);

        expect(result.grid[0][0], 2);
      },
    );
  });

  group('isGameOver', () {
    test('retorna false quando há ao menos uma célula vazia', () {
      final board = Board([
        [2, 4, 8, 16],
        [4, 2, 16, 8],
        [8, 16, 2, 4],
        [16, 8, 4, 0], // única célula vazia
      ]);

      expect(engine.isGameOver(board), isFalse);
    });

    test(
      'retorna false quando o tabuleiro está cheio mas ainda há merge possível',
      () {
        final board = Board([
          [2, 4, 8, 16],
          [4, 2, 16, 8],
          [8, 16, 2, 4],
          [16, 8, 4, 4], // os dois últimos 4s podem se fundir
        ]);

        expect(engine.isGameOver(board), isFalse);
      },
    );

    test(
      'retorna true quando o tabuleiro está cheio e sem nenhum merge possível',
      () {
        final board = Board([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 2],
        ]);

        expect(engine.isGameOver(board), isTrue);
      },
    );

    test(
      'regressão: tabuleiro com 1 linha vazia NUNCA deve ser considerado game over',
      () {
        // Esse é o cenário-gatilho da conversa: mesmo com pouquíssimo espaço,
        // ainda existe jogada possível (mover para baixo), então isGameOver
        // tem que ser false.
        final board = Board([
          [4, 8, 2, 8],
          [16, 2, 4, 2],
          [4, 8, 16, 32],
          [0, 0, 0, 0],
        ]);

        expect(engine.isGameOver(board), isFalse);
      },
    );
  });

  group('hasWon', () {
    test(
      'retorna true quando existe um tile com o valor de vitória (2048)',
      () {
        final board = Board([
          [2048, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        expect(engine.hasWon(board), isTrue);
      },
    );

    test('retorna false quando nenhum tile atingiu o valor de vitória', () {
      final board = Board([
        [1024, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      expect(engine.hasWon(board), isFalse);
    });

    test('aceita um winValue customizado', () {
      final board = Board([
        [64, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);

      expect(engine.hasWon(board, winValue: 64), isTrue);
    });
  });
}
