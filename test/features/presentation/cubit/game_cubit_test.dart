import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/start_new_game_use_case.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_cubit.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_state.dart';

class MockStartNewGameUseCase extends Mock implements StartNewGameUseCase {}

class MockMakeMoveUseCase extends Mock implements MakeMoveUseCase {}

class MockBoard extends Mock implements Board {}

void main() {
  late GameCubit gameCubit;
  late MockStartNewGameUseCase mockStartNewGame;
  late MockMakeMoveUseCase mockMakeMove;
  late Board initialBoard;
  late Board nextBoard;

  setUpAll(() {
    registerFallbackValue(Direction.left);
    registerFallbackValue(Board.empty());
  });

  setUp(() {
    mockStartNewGame = MockStartNewGameUseCase();
    mockMakeMove = MockMakeMoveUseCase();
    initialBoard = Board.empty();
    nextBoard = Board.empty();

    when(() => mockStartNewGame.call()).thenReturn(initialBoard);

    gameCubit = GameCubit(
      startNewGame: mockStartNewGame,
      makeMove: mockMakeMove,
    );
  });
  tearDown(() {
    gameCubit.close();
  });

  group('GameCubit - Inicialização e Reset', () {
    test(
      'GIVEN the GameCubit is instantiated\n'
      'WHEN it initializes\n'
      'THEN it should automatically start a new game with an initial board',
      () {
        // Given & When - handled by setUp

        // Then
        expect(gameCubit.state.board, initialBoard);
        expect(gameCubit.state.score, 0);
        expect(gameCubit.state.status, GameStatus.playing);
        verify(() => mockStartNewGame.call()).called(1);
      },
    );
  });

  group('GameCubit - Movimentação', () {
    blocTest<GameCubit, GameState>(
      'GIVEN a playing game status and a valid board movement\n'
      'WHEN handleMove is called\n'
      'THEN it should update the board, score, and high score',
      build: () {
        when(() => mockMakeMove.call(initialBoard, Direction.left)).thenReturn(
          MakeMoveResult(
            board: nextBoard,
            scoreGained: 16,
            moved: true,
            status: GameStatus.playing,
          ),
        );
        return gameCubit;
      },
      act: (cubit) => cubit.handleMove(Direction.left),
      expect: () => [
        isA<GameState>()
            .having((s) => s.board, 'board', nextBoard)
            .having((s) => s.score, 'score', 16)
            .having((s) => s.highScore, 'highScore', 16)
            .having((s) => s.status, 'status', GameStatus.playing),
      ],
    );

    blocTest<GameCubit, GameState>(
      'GIVEN a move that results in a lower score than high score\n'
      'WHEN handleMove is called\n'
      'THEN it should update the current score but keep the existing high score',
      seed: () => GameState(
        board: initialBoard,
        score: 10,
        highScore: 50,
        status: GameStatus.playing,
      ),
      build: () {
        when(() => mockMakeMove.call(initialBoard, Direction.right)).thenReturn(
          MakeMoveResult(
            board: nextBoard,
            scoreGained: 20,
            moved: true,
            status: GameStatus.playing,
          ),
        );
        return gameCubit;
      },
      act: (cubit) => cubit.handleMove(Direction.right),
      expect: () => [
        isA<GameState>()
            .having((s) => s.score, 'score', 30) // 10 + 20
            .having((s) => s.highScore, 'highScore', 50) // remains 50
            .having((s) => s.board, 'board', nextBoard),
      ],
    );

    blocTest<GameCubit, GameState>(
      'GIVEN a movement that causes no change and status remains the same\n'
      'WHEN handleMove is called\n'
      'THEN it should ignore the action and emit nothing',
      build: () {
        when(() => mockMakeMove.call(initialBoard, Direction.up)).thenReturn(
          MakeMoveResult(
            board: initialBoard,
            scoreGained: 0,
            moved: false,
            status: GameStatus.playing,
          ),
        );
        return gameCubit;
      },
      act: (cubit) => cubit.handleMove(Direction.up),
      expect: () => <GameState>[], // No state emitted
    );

    blocTest<GameCubit, GameState>(
      'GIVEN a game status that is already won or gameOver\n'
      'WHEN handleMove is called\n'
      'THEN it should immediately return and emit nothing without calling the use case',
      seed: () => GameState(
        board: initialBoard,
        score: 100,
        highScore: 100,
        status: GameStatus.gameOver,
      ),
      build: () => gameCubit,
      act: (cubit) => cubit.handleMove(Direction.down),
      expect: () => <GameState>[],
      verify: (_) {
        verifyNever(() => mockMakeMove.call(any(), any()));
      },
    );

    blocTest<GameCubit, GameState>(
      'GIVEN a valid movement that triggers a gameOver condition\n'
      'WHEN handleMove is called\n'
      'THEN it should update the board and change status to gameOver',
      build: () {
        when(() => mockMakeMove.call(initialBoard, Direction.down)).thenReturn(
          MakeMoveResult(
            board: nextBoard,
            scoreGained: 4,
            moved: true,
            status: GameStatus.gameOver,
          ),
        );
        return gameCubit;
      },
      act: (cubit) => cubit.handleMove(Direction.down),
      expect: () => [
        isA<GameState>()
            .having((s) => s.board, 'board', nextBoard)
            .having((s) => s.status, 'status', GameStatus.gameOver),
      ],
    );
  });
}
