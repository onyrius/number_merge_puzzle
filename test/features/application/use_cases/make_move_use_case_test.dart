import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';

import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';

// Cria o Mock para o BoardEngine
class MockBoardEngine extends Mock implements BoardEngine {}

// Cria o Mock simples para o Board para facilitar as passagens de parâmetros nos testes
class MockBoard extends Mock implements Board {}

void main() {
  late MakeMoveUseCase useCase;
  late MockBoardEngine mockEngine;
  late Board initialBoard;
  late Board movedBoard;
  late Board spawnedBoard;

  setUpAll(() {
    // 1. Registra o fallback do Direction (que já estava lá)
    registerFallbackValue(Direction.left);

    // 2. Registra o fallback do Board para o mocktail saber lidar com any() para esse tipo
    registerFallbackValue(Board.empty());
  });

  setUp(() {
    mockEngine = MockBoardEngine();
    useCase = MakeMoveUseCase(mockEngine);

    initialBoard = Board.empty();
    movedBoard = Board.empty();
    spawnedBoard = Board.empty();
  });

  group('MakeMoveUseCase Tests', () {
    test(
      'should return status playing and not spawn a tile when the board does not move',
      () {
        // Arrange
        when(() => mockEngine.move(initialBoard, any())).thenReturn(
          MoveResult(board: initialBoard, scoreGained: 0, moved: false),
        );
        when(() => mockEngine.isGameOver(initialBoard)).thenReturn(false);

        // Act
        final result = useCase.call(initialBoard, Direction.left);

        // Assert
        expect(result.moved, false);
        expect(result.scoreGained, 0);
        expect(result.status, GameStatus.playing);
        expect(result.board, initialBoard);

        // Garante que o método de spawnar bloco NUNCA foi chamado já que o tabuleiro não se mexeu
        verifyNever(() => mockEngine.spawnRandomTile(any()));
      },
    );

    test(
      'should return status gameOver when the board does not move and no moves are left',
      () {
        // Arrange
        when(() => mockEngine.move(initialBoard, any())).thenReturn(
          MoveResult(board: initialBoard, scoreGained: 0, moved: false),
        );
        when(() => mockEngine.isGameOver(initialBoard)).thenReturn(true);

        // Act
        final result = useCase.call(initialBoard, Direction.up);

        // Assert
        expect(result.moved, false);
        expect(result.status, GameStatus.gameOver);
        expect(result.board, initialBoard);
      },
    );

    test(
      'should spawn a new tile and return status playing when a valid move occurs without win or game over',
      () {
        // Arrange
        when(() => mockEngine.move(initialBoard, Direction.right)).thenReturn(
          MoveResult(board: movedBoard, scoreGained: 16, moved: true),
        );
        when(
          () => mockEngine.spawnRandomTile(movedBoard),
        ).thenReturn(spawnedBoard);
        when(() => mockEngine.hasWon(spawnedBoard)).thenReturn(false);
        when(() => mockEngine.isGameOver(spawnedBoard)).thenReturn(false);

        // Act
        final result = useCase.call(initialBoard, Direction.right);

        // Assert
        expect(result.moved, true);
        expect(result.scoreGained, 16);
        expect(result.status, GameStatus.playing);
        expect(
          result.board,
          spawnedBoard,
        ); // O tabuleiro retornado deve conter o novo tile spawnado

        verify(() => mockEngine.spawnRandomTile(movedBoard)).called(1);
      },
    );

    test(
      'should return status won when a valid move results in reaching the winning tile',
      () {
        // Arrange
        when(() => mockEngine.move(initialBoard, Direction.down)).thenReturn(
          MoveResult(board: movedBoard, scoreGained: 32, moved: true),
        );
        when(
          () => mockEngine.spawnRandomTile(movedBoard),
        ).thenReturn(spawnedBoard);
        when(() => mockEngine.hasWon(spawnedBoard)).thenReturn(true);
        // isGameOver não deve ser checado se hasWon for true baseado no fluxo do if/else if

        // Act
        final result = useCase.call(initialBoard, Direction.down);

        // Assert
        expect(result.moved, true);
        expect(result.scoreGained, 32);
        expect(result.status, GameStatus.won);
        expect(result.board, spawnedBoard);
      },
    );

    test(
      'should return status gameOver when a valid move fills the board and leaves no available moves',
      () {
        // Arrange
        when(() => mockEngine.move(initialBoard, Direction.left)).thenReturn(
          MoveResult(board: movedBoard, scoreGained: 4, moved: true),
        );
        when(
          () => mockEngine.spawnRandomTile(movedBoard),
        ).thenReturn(spawnedBoard);
        when(() => mockEngine.hasWon(spawnedBoard)).thenReturn(false);
        when(() => mockEngine.isGameOver(spawnedBoard)).thenReturn(true);

        // Act
        final result = useCase.call(initialBoard, Direction.left);

        // Assert
        expect(result.moved, true);
        expect(result.scoreGained, 4);
        expect(result.status, GameStatus.gameOver);
        expect(result.board, spawnedBoard);
      },
    );
  });
}
