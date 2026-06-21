import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_cubit.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_state.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/game_board_widget.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/score_card_widget.dart';
import 'package:number_merge_puzzle/features/presentation/screens/game_screen.dart';

class MockGameCubit extends MockCubit<GameState> implements GameCubit {}

void main() {
  late MockGameCubit mockGameCubit;
  late GameState initialGameState;

  setUp(() {
    mockGameCubit = MockGameCubit();

    initialGameState = GameState(
      board: Board([
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]),
      score: 100,
      highScore: 500,
      status: GameStatus.playing,
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<GameCubit>.value(
        value: mockGameCubit,
        child: const GameScreen(),
      ),
    );
  }

  group('GameScreen - Rendering and Initial State', () {
    testWidgets(
      'GIVEN a playing game state\n'
      'WHEN the GameScreen is pumped\n'
      'THEN it should display the title, scores, and the game board correctly',
      (WidgetTester tester) async {
        when(() => mockGameCubit.state).thenReturn(initialGameState);

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Merge\nLogic'), findsOneWidget);
        expect(find.byType(GameBoardWidget), findsOneWidget);

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ScoreCardWidget &&
                widget.title == 'SCORE' &&
                widget.value == 100,
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ScoreCardWidget &&
                widget.title == 'BEST' &&
                widget.value == 500,
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('GameScreen - User Interactions', () {
    testWidgets('GIVEN the user taps the refresh button\n'
        'WHEN the tap event occurs\n'
        'THEN it should invoke resetGame on the GameCubit', (
      WidgetTester tester,
    ) async {
      when(() => mockGameCubit.state).thenReturn(initialGameState);
      when(() => mockGameCubit.resetGame()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      final refreshButton = find.byIcon(Icons.refresh_rounded);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();

      verify(() => mockGameCubit.resetGame()).called(1);
    });
  });

  group('GameScreen - BlocListener and Status Dialogs', () {
    testWidgets('GIVEN a state transition from playing to gameOver\n'
        'WHEN the cubit emits the gameOver state\n'
        'THEN the BlocListener should trigger the game over dialog', (
      WidgetTester tester,
    ) async {
      final gameOverState = GameState(
        board: initialGameState.board,
        score: 150,
        highScore: 500,
        status: GameStatus.gameOver,
      );

      whenListen(
        mockGameCubit,
        Stream.fromIterable([initialGameState, gameOverState]),
        initialState: initialGameState,
      );

      when(() => mockGameCubit.state).thenReturn(gameOverState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Game Over!'), findsOneWidget);
      expect(find.text('Pontuação: 150'), findsOneWidget);
    });
  });
}
