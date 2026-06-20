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
      '''Given a board that cannot be moved in the chosen direction and the game is not over
When MakeMoveUseCase is called
Then it should return a playing status, zero score, and should not spawn a new tile''',
      () {
        // Given
        when(() => mockEngine.move(initialBoard, any())).thenReturn(
          MoveResult(board: initialBoard, scoreGained: 0, moved: false),
        );
        when(() => mockEngine.isGameOver(initialBoard)).thenReturn(false);

        // When
        final result = useCase.call(initialBoard, Direction.left);

        // Then
        expect(result.moved, false);
        expect(result.scoreGained, 0);
        expect(result.status, GameStatus.playing);
        expect(result.board, initialBoard);

        // Garante que o método de spawnar bloco NUNCA foi chamado já que o tabuleiro não se mexeu
        verifyNever(() => mockEngine.spawnRandomTile(any()));
      },
    );

    test(
      '''Given a board that cannot be moved in the chosen direction and no moves are left
When MakeMoveUseCase is called
Then it should return a gameOver status''',
      () {
        // Given
        when(() => mockEngine.move(initialBoard, any())).thenReturn(
          MoveResult(board: initialBoard, scoreGained: 0, moved: false),
        );
        when(() => mockEngine.isGameOver(initialBoard)).thenReturn(true);

        // When
        final result = useCase.call(initialBoard, Direction.up);

        // Then
        expect(result.moved, false);
        expect(result.status, GameStatus.gameOver);
        expect(result.board, initialBoard);
      },
    );

    test(
      '''Given a valid move that changes the board without winning or ending the game
When MakeMoveUseCase is called
Then it should spawn a new tile and return a playing status with the gained score''',
      () {
        // Given
        when(() => mockEngine.move(initialBoard, Direction.right)).thenReturn(
          MoveResult(board: movedBoard, scoreGained: 16, moved: true),
        );
        when(
          () => mockEngine.spawnRandomTile(movedBoard),
        ).thenReturn(spawnedBoard);
        when(() => mockEngine.hasWon(spawnedBoard)).thenReturn(false);
        when(() => mockEngine.isGameOver(spawnedBoard)).thenReturn(false);

        // When
        final result = useCase.call(initialBoard, Direction.right);

        // Then
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
      '''Given a valid move that results in reaching the winning tile value
When MakeMoveUseCase is called
Then it should spawn a new tile and return a won status''',
      () {
        // Given
        when(() => mockEngine.move(initialBoard, Direction.down)).thenReturn(
          MoveResult(board: movedBoard, scoreGained: 32, moved: true),
        );
        when(
          () => mockEngine.spawnRandomTile(movedBoard),
        ).thenReturn(spawnedBoard);
        when(() => mockEngine.hasWon(spawnedBoard)).thenReturn(true);

        // When
        final result = useCase.call(initialBoard, Direction.down);

        // Then
        expect(result.moved, true);
        expect(result.scoreGained, 32);
        expect(result.status, GameStatus.won);
        expect(result.board, spawnedBoard);
      },
    );

    test(
      '''Given a valid move that completely fills the board leaving no available moves left
When MakeMoveUseCase is called
Then it should spawn a new tile and return a gameOver status''',
      () {
        // Given
        when(() => mockEngine.move(initialBoard, Direction.left)).thenReturn(
          MoveResult(board: movedBoard, scoreGained: 4, moved: true),
        );
        when(
          () => mockEngine.spawnRandomTile(movedBoard),
        ).thenReturn(spawnedBoard);
        when(() => mockEngine.hasWon(spawnedBoard)).thenReturn(false);
        when(() => mockEngine.isGameOver(spawnedBoard)).thenReturn(true);

        // When
        final result = useCase.call(initialBoard, Direction.left);

        // Then
        expect(result.moved, true);
        expect(result.scoreGained, 4);
        expect(result.status, GameStatus.gameOver);
        expect(result.board, spawnedBoard);
      },
    );
  });
}
