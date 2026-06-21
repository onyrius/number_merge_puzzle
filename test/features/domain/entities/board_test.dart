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

  _FixedRandom({this.doubleValue = 0.5}) : intValue = 0;

  @override
  int nextInt(int max) => intValue;

  @override
  double nextDouble() => doubleValue;

  @override
  bool nextBool() => false;

  Random get secure => this;
}

void main() {
  late BoardEngine engine;

  setUp(() {
    engine = BoardEngine(random: _FixedRandom());
  });

  group('moveLeft (via Direction.left)', () {
    test(
      '''Given a board row with non-zero values separated by zeros
When move is called with Direction.left
Then it should compress non-zero values to the left without merging''',
      () {
        // Given
        final board = Board([
          [0, 2, 0, 4],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.left);

        // Then
        expect(result.board.grid[0], [2, 4, 0, 0]);
        expect(result.moved, isTrue);
        expect(result.scoreGained, 0);
      },
    );

    test(
      '''Given a board row with two identical adjacent values
When move is called with Direction.left
Then it should merge them into a single tile and add to the score''',
      () {
        // Given
        final board = Board([
          [2, 2, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.left);

        // Then
        expect(result.board.grid[0], [4, 0, 0, 0]);
        expect(result.scoreGained, 4);
        expect(result.moved, isTrue);
      },
    );

    test(
      '''Given a board row fully populated with identical values
When move is called with Direction.left
Then it should not merge the same cell twice in a single turn''',
      () {
        // Given - [2, 2, 2, 2] should become [4, 4, 0, 0], not [8, 0, 0, 0]
        final board = Board([
          [2, 2, 2, 2],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.left);

        // Then
        expect(result.board.grid[0], [4, 4, 0, 0]);
        expect(result.scoreGained, 8);
      },
    );

    test(
      '''Given a board that is already in its final compressed state on the left
When move is called with Direction.left
Then it should report moved as false and keep the grid intact''',
      () {
        // Given
        final board = Board([
          [2, 4, 8, 16],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.left);

        // Then
        expect(result.moved, isFalse);
        expect(result.board.grid[0], [2, 4, 8, 16]);
      },
    );
  });

  group('moveRight', () {
    test(
      '''Given a board row with scattered values
When move is called with Direction.right
Then it should compress values to the right''',
      () {
        // Given
        final board = Board([
          [2, 0, 4, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.right);

        // Then
        expect(result.board.grid[0], [0, 0, 2, 4]);
        expect(result.moved, isTrue);
      },
    );

    test(
      '''Given a board row with identical values at the right edge
When move is called with Direction.right
Then it should merge the values into the right-most cell''',
      () {
        // Given
        final board = Board([
          [0, 0, 4, 4],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.right);

        // Then
        expect(result.board.grid[0], [0, 0, 0, 8]);
        expect(result.scoreGained, 8);
      },
    );
  });

  group('moveUp', () {
    test(
      '''Given a board column with scattered values
When move is called with Direction.up
Then it should compress values vertically towards the top row''',
      () {
        // Given
        final board = Board([
          [0, 0, 0, 0],
          [2, 0, 0, 0],
          [0, 0, 0, 0],
          [4, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.up);

        // Then
        expect(result.board.grid[0][0], 2);
        expect(result.board.grid[1][0], 4);
        expect(result.board.grid[2][0], 0);
        expect(result.board.grid[3][0], 0);
        expect(result.moved, isTrue);
      },
    );
  });

  group('moveDown — cenário do bug caçado na conversa', () {
    test(
      '''Given a nearly full board with only the last row empty and no possible merges
When move is called with Direction.down
Then it should slide all columns to the bottom and return moved as true''',
      () {
        // Given - Exact reported scenario: 3 rows filled, 1 empty row at the bottom.
        final board = Board([
          [4, 8, 2, 8],
          [16, 2, 4, 2],
          [4, 8, 16, 32],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.down);

        // Then
        expect(
          result.moved,
          isTrue,
          reason:
              'There is an empty row at the bottom; moving down MUST produce a change, even without any merges.',
        );
        expect(result.board.grid, [
          [0, 0, 0, 0],
          [4, 8, 2, 8],
          [16, 2, 4, 2],
          [4, 8, 16, 32],
        ]);
        expect(result.scoreGained, 0);
      },
    );

    test(
      '''Given a board from the second reported screenshot with one filled row and scattered tiles
When move is called with Direction.down
Then it should compress all columns down to their correct geometric positions''',
      () {
        // Given
        final board = Board([
          [4, 8, 2, 8],
          [0, 16, 64, 4],
          [0, 0, 4, 32],
          [0, 0, 2, 8],
        ]);

        // When
        final result = engine.move(board, Direction.down);

        // Then
        expect(result.moved, isTrue);
        expect(result.board.grid, [
          [0, 0, 2, 8],
          [0, 0, 64, 4],
          [0, 8, 4, 32],
          [4, 16, 2, 8],
        ]);
      },
    );

    test(
      '''Given a board with tiles at the top
When move is called with Direction.down
Then it should not produce the same result as moveUp''',
      () {
        // Given - Regression test for the transposition/reversal order bug
        final board = Board([
          [2, 4, 8, 16],
          [32, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final downResult = engine.move(board, Direction.down);
        final upResult = engine.move(board, Direction.up);

        // Then
        expect(downResult.board.grid, isNot(equals(upResult.board.grid)));

        expect(downResult.board.grid, [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [2, 0, 0, 0],
          [32, 4, 8, 16],
        ]);

        expect(upResult.moved, isFalse);
      },
    );

    test(
      '''Given a board with a possible vertical merge downwards
When move is called with Direction.down
Then it should merge the matching adjacent vertical pair correctly''',
      () {
        // Given
        final board = Board([
          [2, 0, 0, 0],
          [2, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final result = engine.move(board, Direction.down);

        // Then
        expect(result.board.grid[3][0], 4);
        expect(result.scoreGained, 4);
        expect(result.moved, isTrue);
      },
    );

    test(
      '''Given a settled board shifted down
When move is called with Direction.up
Then down and up operations should act as inverse matrix transformations''',
      () {
        // Given
        final original = Board([
          [2, 4, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When
        final afterDown = engine.move(original, Direction.down);
        final afterUpAgain = engine.move(afterDown.board, Direction.up);

        // Then
        expect(afterUpAgain.board.grid[0], [2, 4, 0, 0]);
      },
    );
  });

  group('spawnRandomTile', () {
    test(
      '''Given a board with empty cells
When spawnRandomTile is called
Then it should insert exactly one new tile into an empty cell''',
      () {
        // Given
        final board = Board.empty();

        // When
        final result = engine.spawnRandomTile(board);

        // Then
        final nonZeroCount = result.grid
            .expand((row) => row)
            .where((v) => v != 0)
            .length;
        expect(nonZeroCount, 1);
      },
    );

    test(
      '''Given a fully populated board with no empty cells
When spawnRandomTile is called
Then it should return the board unchanged''',
      () {
        // Given
        final fullBoard = Board(
          List.generate(4, (_) => List.generate(4, (_) => 2)),
        );

        // When
        final result = engine.spawnRandomTile(fullBoard);

        // Then
        expect(result.grid, fullBoard.grid);
      },
    );

    test(
      '''Given a FixedRandom instance configured with a high double value of 0.95
When spawnRandomTile is called
Then it should insert a tile with the value of 4''',
      () {
        // Given
        final engineWithHighRandom = BoardEngine(
          random: _FixedRandom(doubleValue: 0.95),
        );
        final board = Board.empty();

        // When
        final result = engineWithHighRandom.spawnRandomTile(board);

        // Then
        expect(result.grid[0][0], 4);
      },
    );

    test(
      '''Given a FixedRandom instance configured with a low double value of 0.1
When spawnRandomTile is called
Then it should insert a tile with the value of 2''',
      () {
        // Given
        final engineWithLowRandom = BoardEngine(
          random: _FixedRandom(doubleValue: 0.1),
        );
        final board = Board.empty();

        // When
        final result = engineWithLowRandom.spawnRandomTile(board);

        // Then
        expect(result.grid[0][0], 2);
      },
    );
  });

  group('isGameOver', () {
    test(
      '''Given a board that contains at least one empty cell
When isGameOver is checked
Then it should return false''',
      () {
        // Given
        final board = Board([
          [2, 4, 8, 16],
          [4, 2, 16, 8],
          [8, 16, 2, 4],
          [16, 8, 4, 0], // single empty cell
        ]);

        // When & Then
        expect(engine.isGameOver(board), isFalse);
      },
    );

    test(
      '''Given a completely full board that still has at least one adjacent matching pair
When isGameOver is checked
Then it should return false''',
      () {
        // Given
        final board = Board([
          [2, 4, 8, 16],
          [4, 2, 16, 8],
          [8, 16, 2, 4],
          [16, 8, 4, 4], // the last two 4s can merge
        ]);

        // When & Then
        expect(engine.isGameOver(board), isFalse);
      },
    );

    test(
      '''Given a completely full board with absolutely no available merges left
When isGameOver is checked
Then it should return true''',
      () {
        // Given
        final board = Board([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 2],
        ]);

        // When & Then
        expect(engine.isGameOver(board), isTrue);
      },
    );

    test(
      '''Given a board with one entirely empty row at the bottom
When isGameOver is checked
Then it should always return false''',
      () {
        // Given - Trigger scenario from the conversation: moving down is still possible
        final board = Board([
          [4, 8, 2, 8],
          [16, 2, 4, 2],
          [4, 8, 16, 32],
          [0, 0, 0, 0],
        ]);

        // When & Then
        expect(engine.isGameOver(board), isFalse);
      },
    );
  });

  group('hasWon', () {
    test(
      '''Given a board containing at least one tile with the default victory value of 2048
When hasWon is checked
Then it should return true''',
      () {
        // Given
        final board = Board([
          [2048, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When & Then
        expect(engine.hasWon(board), isTrue);
      },
    );

    test(
      '''Given a board where no tiles have reached the victory value
When hasWon is checked
Then it should return false''',
      () {
        // Given
        final board = Board([
          [1024, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When & Then
        expect(engine.hasWon(board), isFalse);
      },
    );

    test(
      '''Given a board containing a custom target value
When hasWon is checked with that custom winValue
Then it should return true''',
      () {
        // Given
        final board = Board([
          [64, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        // When & Then
        expect(engine.hasWon(board, winValue: 64), isTrue);
      },
    );
  });
}
