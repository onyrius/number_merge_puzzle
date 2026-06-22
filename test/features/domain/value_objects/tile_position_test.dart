import 'package:flutter_test/flutter_test.dart';
import 'package:number_merge_puzzle/features/domain/value_objects/tile_position.dart';

void main() {
  group('TilePosition - Instantiation and Properties', () {
    test('GIVEN row and col values\n'
        'WHEN a new TilePosition is instantiated\n'
        'THEN properties should be set correctly', () {
      final position = TilePosition(2, 3);

      expect(position.row, equals(2));
      expect(position.col, equals(3));
    });
  });

  group('TilePosition - Equality (operator ==)', () {
    test('GIVEN two positions with identical row and col\n'
        'WHEN they are compared using operator ==\n'
        'THEN they should be considered equal', () {
      final pos1 = TilePosition(1, 5);
      final pos2 = TilePosition(1, 5);

      expect(pos1 == pos2, isTrue);
    });

    test('GIVEN two positions with different row or col\n'
        'WHEN they are compared using operator ==\n'
        'THEN they should not be considered equal', () {
      final basePos = TilePosition(2, 2);
      final diffRow = TilePosition(3, 2);
      final diffCol = TilePosition(2, 4);

      expect(basePos == diffRow, isFalse);
      expect(basePos == diffCol, isFalse);
    });

    test('GIVEN a position and an object of a different type\n'
        'WHEN they are compared using operator ==\n'
        'THEN they should not be considered equal', () {
      final position = TilePosition(0, 0);
      final Object diffType = {'row': 0, 'col': 0};

      expect(position == diffType, isFalse);
    });
  });

  group('TilePosition - Hash Code and Collections', () {
    test('GIVEN two positions with identical values\n'
        'WHEN hashCode is requested\n'
        'THEN both hashCodes must match perfectly', () {
      final pos1 = TilePosition(4, 4);
      final pos2 = TilePosition(4, 4);

      expect(pos1.hashCode, equals(pos2.hashCode));
    });

    test(
      'GIVEN duplicate positions\n'
      'WHEN they are added to a Set literal\n'
      'THEN the Set should filter out duplicates in runtime using hashCode',
      () {
        final pos1 = TilePosition(1, 1);
        final pos2 = TilePosition(1, 1);
        final pos3 = TilePosition(1, 2);

        final positionSet = <TilePosition>{pos1, pos2, pos3};

        expect(positionSet.length, equals(2));
        expect(positionSet, contains(TilePosition(1, 1)));
      },
    );
  });

  group('TilePosition - String Representation', () {
    test('GIVEN a valid position\n'
        'WHEN toString is called\n'
        'THEN it should return the formatted domain string', () {
      final position = TilePosition(7, 9);

      expect(position.toString(), equals('TilePosition(7, 9)'));
    });
  });
}
