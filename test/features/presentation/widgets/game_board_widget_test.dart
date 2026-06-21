import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_merge_puzzle/features/domain/entities/board.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/game_board_widget.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/tile_widget.dart';

void main() {
  late Board emptyBoard;

  setUp(() {
    emptyBoard = Board([
      [2, 0, 0, 0],
      [0, 4, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 8],
    ]);
  });

  Widget createWidgetUnderTest({
    required Board board,
    required double size,
    required ValueChanged<Direction> onSwipe,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GameBoardWidget(board: board, size: size, onSwipe: onSwipe),
      ),
    );
  }

  group('GameBoardWidget - Rendering', () {
    testWidgets(
      'GIVEN a board state and a specific size\n'
      'WHEN the GameBoardWidget is pumped\n'
      'THEN it should render with the exact dimensions and contain all tiles',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            board: emptyBoard,
            size: 360.0,
            onSwipe: (_) {},
          ),
        );

        final containerFinder = find.byType(Container).first;
        final Size containerSize = tester.getSize(containerFinder);

        expect(containerSize.width, equals(360.0));
        expect(containerSize.height, equals(360.0));

        expect(find.byType(TileWidget), findsNWidgets(16));
        expect(find.text('2'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      },
    );
  });

  group('GameBoardWidget - Gestures and Input', () {
    testWidgets('GIVEN a user drag gesture to the left\n'
        'WHEN the drag finishes on the game board\n'
        'THEN it should trigger the onSwipe callback with Direction.left', (
      WidgetTester tester,
    ) async {
      Direction? detectedDirection;

      await tester.pumpWidget(
        createWidgetUnderTest(
          board: emptyBoard,
          size: 400.0,
          onSwipe: (direction) {
            detectedDirection = direction;
          },
        ),
      );

      final boardFinder = find.byType(GameBoardWidget);

      await tester.drag(boardFinder, const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(detectedDirection, equals(Direction.left));
    });

    testWidgets('GIVEN a user drag gesture upwards\n'
        'WHEN the drag finishes on the game board\n'
        'THEN it should trigger the onSwipe callback with Direction.up', (
      WidgetTester tester,
    ) async {
      Direction? detectedDirection;

      await tester.pumpWidget(
        createWidgetUnderTest(
          board: emptyBoard,
          size: 400.0,
          onSwipe: (direction) {
            detectedDirection = direction;
          },
        ),
      );

      final boardFinder = find.byType(GameBoardWidget);

      await tester.drag(boardFinder, const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(detectedDirection, equals(Direction.up));
    });
  });
}
