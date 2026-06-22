import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_merge_puzzle/features/application/use_cases/load_game_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/save_game_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/start_new_game_use_case.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';
import 'package:number_merge_puzzle/features/core/app_strings.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_cubit.dart';
import 'package:number_merge_puzzle/features/presentation/screens/game_screen.dart';
import 'package:number_merge_puzzle/infrastructure/persistence/shared_prefs_fame_repository.dart';

void main() {
  runApp(const NumberMergeGame());
}

class NumberMergeGame extends StatelessWidget {
  const NumberMergeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: BlocProvider<GameCubit>(
        create: (_) {
          final engine = BoardEngine();
          final repository = SharedPrefsGameRepository();

          return GameCubit(
            startNewGame: StartNewGameUseCase(engine),
            makeMove: MakeMoveUseCase(engine),
            saveGame: SaveGameUseCase(repository),
            loadGame: LoadGameUseCase(repository),
          );
        },
        child: const GameScreen(),
      ),
    );
  }
}
