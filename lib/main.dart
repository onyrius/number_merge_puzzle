import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/start_new_game_use_case.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_cubit.dart';
import 'package:number_merge_puzzle/features/presentation/screens/game_screen.dart';

void main() {
  runApp(const NumberMergeGame());
}

class NumberMergeGame extends StatelessWidget {
  const NumberMergeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Number Merge Puzzle',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      // A "composition root": é aqui, e só aqui, que montamos manualmente
      // o grafo de dependências (engine → use cases → cubit).
      // Nenhuma outra camada do app sabe como essas peças são construídas.
      home: BlocProvider<GameCubit>(
        create: (_) {
          final engine = BoardEngine();
          return GameCubit(
            startNewGame: StartNewGameUseCase(engine),
            makeMove: MakeMoveUseCase(engine),
          );
        },
        child: const GameScreen(),
      ),
    );
  }
}
