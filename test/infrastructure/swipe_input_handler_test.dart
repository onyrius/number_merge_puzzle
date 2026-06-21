import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';
import 'package:number_merge_puzzle/infrastructure/swipe_input_handler.dart';

void main() {
  late SwipeInputHandler handler;

  setUp(() {
    handler = SwipeInputHandler();
  });

  group('SwipeInputHandler Tests', () {
    test(
      '''Given no start gesture was ever registered
            When onPanEnd is called
            Then it should return null''',
      () {
        // Given - empty state

        // When
        final result = handler.onPanEnd(DragEndDetails());

        // Then
        expect(result, isNull);
      },
    );

    test(
      '''Given a user touches the screen but barely moves their finger
When the drag distance is smaller than the minimum required
Then it should return null''',
      () {
        // Given
        handler.onPanStart(
          DragStartDetails(globalPosition: const Offset(100, 100)),
        );
        handler.onPanUpdate(
          DragUpdateDetails(globalPosition: const Offset(105, 105)),
        );

        // When
        final result = handler.onPanEnd(DragEndDetails());

        // Then
        expect(result, isNull);
      },
    );

    test(
      '''Given a swipe gesture moving 50px right and 0px vertically
When onPanEnd is called
Then it should return Direction.right''',
      () {
        // Given
        handler.onPanStart(
          DragStartDetails(globalPosition: const Offset(100, 100)),
        );
        handler.onPanUpdate(
          DragUpdateDetails(globalPosition: const Offset(150, 100)),
        );

        // When
        final result = handler.onPanEnd(DragEndDetails());

        // Then
        expect(result, Direction.right);
      },
    );

    test(
      '''Given a swipe gesture moving 50px left and only 5px down
When onPanEnd is called
Then it should return Direction.left''',
      () {
        // Given
        handler.onPanStart(
          DragStartDetails(globalPosition: const Offset(100, 100)),
        );
        handler.onPanUpdate(
          DragUpdateDetails(globalPosition: const Offset(50, 105)),
        );

        // When
        final result = handler.onPanEnd(DragEndDetails());

        // Then
        expect(result, Direction.left);
      },
    );

    test(
      '''Given a swipe gesture moving 60px straight down
When onPanEnd is called
Then it should return Direction.down''',
      () {
        // Given
        handler.onPanStart(
          DragStartDetails(globalPosition: const Offset(100, 100)),
        );
        handler.onPanUpdate(
          DragUpdateDetails(globalPosition: const Offset(100, 160)),
        );

        // When
        final result = handler.onPanEnd(DragEndDetails());

        // Then
        expect(result, Direction.down);
      },
    );

    test(
      '''Given a swipe gesture moving 60px straight up and 2px right
When onPanEnd is called
Then it should return Direction.up''',
      () {
        // Given
        handler.onPanStart(
          DragStartDetails(globalPosition: const Offset(100, 100)),
        );
        handler.onPanUpdate(
          DragUpdateDetails(globalPosition: const Offset(102, 40)),
        );

        // When
        final result = handler.onPanEnd(DragEndDetails());

        // Then
        expect(result, Direction.up);
      },
    );

    test(
      '''Given a valid right swipe has been fully completed
When we immediately trigger onPanEnd again without a new touch start
Then it should return null because the state was reset''',
      () {
        // Given
        handler.onPanStart(
          DragStartDetails(globalPosition: const Offset(100, 100)),
        );
        handler.onPanUpdate(
          DragUpdateDetails(globalPosition: const Offset(200, 100)),
        );
        final firstResult = handler.onPanEnd(DragEndDetails());
        expect(firstResult, Direction.right);

        // When
        final secondResult = handler.onPanEnd(DragEndDetails());

        // Then
        expect(secondResult, isNull);
      },
    );
  });
}
