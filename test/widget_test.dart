// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:number_merge_puzzle/main.dart';

void main() {
  testWidgets('Number Merge Game', (WidgetTester tester) async {
    await tester.pumpWidget(const NumberMergeGame());

    expect(find.text('Merge\nLogic'), findsOneWidget);

    await tester.pump();

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
  });
}
