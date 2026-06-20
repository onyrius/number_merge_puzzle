import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_cubit.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_state.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/game_board_widget.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/game_over_dialog.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/score_card_widget.dart';
import 'package:number_merge_puzzle/infrastructure/keyboard_input_handler.dart';

/// Tela principal do jogo.
/// Usa BlocBuilder para reconstruir a UI quando o GameState muda, e
/// BlocListener para reagir a eventos pontuais (mostrar o diálogo de
/// fim de jogo apenas UMA vez, e não a cada rebuild).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _keyboardHandler = KeyboardInputHandler();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _showStatusDialog(BuildContext context, GameStatus status, int score) {
    final isWin = status == GameStatus.won;
    showGameOverDialog(
      context: context,
      title: isWin ? '🎉 Você venceu!' : 'Game Over!',
      content: 'Pontuação: $score',
      onPlayAgain: () => context.read<GameCubit>().resetGame(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth.clamp(0.0, 400.0) - 40;

    return Scaffold(
      body: SafeArea(
        // BlocListener reage a MUDANÇAS de estado (efeitos colaterais),
        // sem reconstruir a árvore de widgets. Ideal para diálogos, snackbars, navegação.
        child: BlocListener<GameCubit, GameState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status != GameStatus.playing) {
              _showStatusDialog(context, state.status, state.score);
            }
          },
          child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (event) {
              final direction = _keyboardHandler.mapKeyEvent(event);
              if (direction != null) {
                context.read<GameCubit>().handleMove(direction);
              }
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BlocBuilder reconstrói SÓ esse trecho quando o estado muda.
                      BlocBuilder<GameCubit, GameState>(
                        builder: (context, state) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Merge\nLogic',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Row(
                                children: [
                                  ScoreCardWidget(
                                    title: 'SCORE',
                                    value: state.score,
                                  ),
                                  const SizedBox(width: 8),
                                  ScoreCardWidget(
                                    title: 'BEST',
                                    value: state.highScore,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '← → ↑ ↓  ou  arraste na tela',
                        style: TextStyle(fontSize: 12, color: Colors.white38),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<GameCubit, GameState>(
                        buildWhen: (previous, current) =>
                            previous.board != current.board,
                        builder: (context, state) {
                          return GameBoardWidget(
                            board: state.board,
                            size: boardSize,
                            onSwipe: context.read<GameCubit>().handleMove,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        onPressed: () => context.read<GameCubit>().resetGame(),
                        icon: const Icon(Icons.refresh_rounded, size: 36),
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
