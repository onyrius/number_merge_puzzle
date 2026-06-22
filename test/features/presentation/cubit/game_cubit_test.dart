import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';
import 'package:number_merge_puzzle/features/application/use_cases/load_game_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart'; // Certifique-se de que MakeMoveResult vem daqui
import 'package:number_merge_puzzle/features/application/use_cases/save_game_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/start_new_game_use_case.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_cubit.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_state.dart';

class MockStartNewGameUseCase extends Mock implements StartNewGameUseCase {}

class MockMakeMoveUseCase extends Mock implements MakeMoveUseCase {}

class MockSaveGameUseCase extends Mock implements SaveGameUseCase {}

class MockLoadGameUseCase extends Mock implements LoadGameUseCase {}

void main() {
  late MockStartNewGameUseCase mockStartNewGame;
  late MockMakeMoveUseCase mockMakeMove;
  late MockSaveGameUseCase mockSaveGame;
  late MockLoadGameUseCase mockLoadGame;
  late Board emptyBoard;

  setUp(() {
    mockStartNewGame = MockStartNewGameUseCase();
    mockMakeMove = MockMakeMoveUseCase();
    mockSaveGame = MockSaveGameUseCase();
    mockLoadGame = MockLoadGameUseCase();

    emptyBoard = Board([
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);

    registerFallbackValue(emptyBoard);
  });

  group('GameCubit - Initialization', () {
    blocTest<GameCubit, GameState>(
      'GIVEN no saved game exists\n'
      'WHEN the GameCubit is initialized\n'
      'THEN it should start a new game and emit a playing state',
      build: () {
        when(() => mockLoadGame()).thenAnswer((_) async => null);
        when(() => mockStartNewGame()).thenReturn(emptyBoard);
        return GameCubit(
          startNewGame: mockStartNewGame,
          makeMove: mockMakeMove,
          saveGame: mockSaveGame,
          loadGame: mockLoadGame,
        );
      },
      expect: () => [
        isA<GameState>()
            .having((s) => s.board, 'board', emptyBoard)
            .having((s) => s.score, 'score', 0)
            .having((s) => s.status, 'status', GameStatus.playing)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });

  group('GameCubit - Actions and Persistence', () {
    blocTest<GameCubit, GameState>(
      'GIVEN an active game\n'
      'WHEN resetGame is invoked\n'
      'THEN it should trigger a new board and persist the state',
      build: () {
        when(() => mockLoadGame()).thenAnswer((_) async => null);
        when(() => mockStartNewGame()).thenReturn(emptyBoard);
        when(
          () => mockSaveGame(
            board: any(named: 'board'),
            score: any(named: 'score'),
            highScore: any(named: 'highScore'),
          ),
        ).thenAnswer((_) async {});

        return GameCubit(
          startNewGame: mockStartNewGame,
          makeMove: mockMakeMove,
          saveGame: mockSaveGame,
          loadGame: mockLoadGame,
        );
      },
      act: (cubit) async {
        await cubit.stream.first;
        cubit.resetGame();
      },
      verify: (_) {
        verify(
          () =>
              mockSaveGame(board: any(named: 'board'), score: 0, highScore: 0),
        ).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'GIVEN a user triggers a move\n'
      'WHEN the move changes the board\n'
      'THEN it should emit the updated score, update highscore, and persist',
      build: () {
        when(() => mockLoadGame()).thenAnswer((_) async => null);
        when(() => mockStartNewGame()).thenReturn(emptyBoard);
        when(
          () => mockSaveGame(
            board: any(named: 'board'),
            score: any(named: 'score'),
            highScore: any(named: 'highScore'),
          ),
        ).thenAnswer((_) async {});

        when(() => mockMakeMove(any(), Direction.left)).thenReturn(
          MakeMoveResult(
            board: emptyBoard,
            moved: true,
            scoreGained: 10,
            status: GameStatus.playing,
          ),
        );

        return GameCubit(
          startNewGame: mockStartNewGame,
          makeMove: mockMakeMove,
          saveGame: mockSaveGame,
          loadGame: mockLoadGame,
        );
      },
      act: (cubit) async {
        // Aguarda a carga inicial terminar para não encavalar os estados de forma imprevisível
        await cubit.stream.first;
        cubit.handleMove(Direction.left);
      },
      // Esperamos os dois estados emitidos após a criação do Cubit
      expect: () => [
        // 1º Estado: Emitido pelo _loadGameOrStartNew() ao terminar de inicializar
        isA<GameState>().having((s) => s.score, 'score', 0),
        // 2º Estado: Emitido pelo handleMove() após a jogada bem-sucedida
        isA<GameState>()
            .having((s) => s.score, 'score', 10)
            .having((s) => s.highScore, 'highScore', 10),
      ],
      verify: (_) {
        verify(
          () => mockSaveGame(
            board: any(named: 'board'),
            score: 10,
            highScore: 10,
          ),
        ).called(1);
      },
    );
  });
}
