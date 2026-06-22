import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:number_merge_puzzle/features/core/app_strings.dart';
import 'package:number_merge_puzzle/main.dart';

void main() {
  testWidgets('Number Merge Game', (WidgetTester tester) async {
    await tester.pumpWidget(const NumberMergeGame());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() ==
                '${AppStrings.gameTitleLight}${AppStrings.gameTitleStrong}',
      ),
      findsOneWidget,
    );

    await tester.pump();

    expect(find.text(AppStrings.scoreLabel), findsOneWidget);
    expect(find.text(AppStrings.bestScoreLabel), findsOneWidget);
  });
}
