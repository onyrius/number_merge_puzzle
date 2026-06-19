import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/presentation/controllers/game_controller.dart';
import 'package:number_merge_puzzle/features/presentation/screens/game_screen.dart';
import 'package:number_merge_puzzle/features/application/use_cases/start_new_game_use_case.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/domain/service/board.engine.dart';

void main() {
  final controller = GameController(
    startNewGame: StartNewGameUseCase(BoardEngine()),
    makeMove: MakeMoveUseCase(BoardEngine()),
  );

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final GameController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merge Logic',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GameScreen(controller: controller),
    );
  }
}
