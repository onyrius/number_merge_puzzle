import 'package:flutter_test/flutter_test.dart';
import 'package:number_merge_puzzle/features/presentation/screens/game_screen.dart';
import 'package:number_merge_puzzle/main.dart' as app;

void main() {
  group('main - App Bootstrap', () {
    testWidgets(
      'GIVEN the production main entrypoint\n'
      'WHEN main is called\n'
      'THEN it should run the NumberMergeGame app',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        expect(find.byType(app.NumberMergeGame), findsOneWidget);
        expect(find.byType(GameScreen), findsOneWidget);
      },
    );
  });

  group('NumberMergeGame - Application Initialization', () {
    testWidgets(
      'GIVEN the production NumberMergeGame widget\n'
      'WHEN the application starts up and is pumped\n'
      'THEN it should build the full dependency tree and inject the GameScreen',
      (WidgetTester tester) async {
        // 1. Executa o ciclo completo de build do app de produção
        // Isso vai forçar o BlocProvider a rodar a linha 29 a 35 do main.dart
        await tester.pumpWidget(const app.NumberMergeGame());
        await tester.pumpAndSettle();

        // 2. Garante que a árvore real de produção montou a GameScreen com sucesso
        expect(find.byType(GameScreen), findsOneWidget);
      },
    );
  });
}
