import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Ajuste o import para o caminho correto do seu projeto
import 'package:number_merge_puzzle/features/domain/value_objects/direction.dart';
import 'package:number_merge_puzzle/infrastructure/keyboard_input_handler.dart';

void main() {
  late KeyboardInputHandler handler;

  setUp(() {
    handler = KeyboardInputHandler();
  });

  group('KeyboardInputHandler Tests', () {
    test('GIVEN an event that is not a KeyDownEvent\n'
        'WHEN mapKeyEvent is called\n'
        'THEN it should return null', () {
      // Arrange
      final keyUpEvent = KeyUpEvent(
        physicalKey: PhysicalKeyboardKey.arrowLeft,
        logicalKey: LogicalKeyboardKey.arrowLeft,
        timeStamp: Duration.zero,
      );

      // Act
      final result = handler.mapKeyEvent(keyUpEvent);

      // Assert
      expect(result, isNull);
    });

    test('GIVEN a KeyDownEvent for the Arrow Left key\n'
        'WHEN mapKeyEvent is called\n'
        'THEN it should return Direction.left', () {
      // Arrange
      final event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowLeft,
        logicalKey: LogicalKeyboardKey.arrowLeft,
        timeStamp: Duration.zero,
      );

      // Act
      final result = handler.mapKeyEvent(event);

      // Assert
      expect(result, Direction.left);
    });

    test('GIVEN a KeyDownEvent for the Arrow Right key\n'
        'WHEN mapKeyEvent is called\n'
        'THEN it should return Direction.right', () {
      // Arrange
      final event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowRight,
        logicalKey: LogicalKeyboardKey.arrowRight,
        timeStamp: Duration.zero,
      );

      // Act
      final result = handler.mapKeyEvent(event);

      // Assert
      expect(result, Direction.right);
    });

    test('GIVEN a KeyDownEvent for the Arrow Up key\n'
        'WHEN mapKeyEvent is called\n'
        'THEN it should return Direction.up', () {
      // Arrange
      final event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowUp,
        logicalKey: LogicalKeyboardKey.arrowUp,
        timeStamp: Duration.zero,
      );

      // Act
      final result = handler.mapKeyEvent(event);

      // Assert
      expect(result, Direction.up);
    });

    test('GIVEN a KeyDownEvent for the Arrow Down key\n'
        'WHEN mapKeyEvent is called\n'
        'THEN it should return Direction.down', () {
      // Arrange
      final event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowDown,
        logicalKey: LogicalKeyboardKey.arrowDown,
        timeStamp: Duration.zero,
      );

      // Act
      final result = handler.mapKeyEvent(event);

      // Assert
      expect(result, Direction.down);
    });

    test('GIVEN a KeyDownEvent for a non-arrow key\n'
        'WHEN mapKeyEvent is called\n'
        'THEN it should return null', () {
      // Arrange
      final event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyA,
        logicalKey: LogicalKeyboardKey.keyA,
        timeStamp: Duration.zero,
      );

      // Act
      final result = handler.mapKeyEvent(event);

      // Assert
      expect(result, isNull);
    });
  });
}
