import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/presentation/controllers/game_controller.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/score_card_widget.dart';
import 'package:number_merge_puzzle/infrastructure/keyboard_input_handler.dart';
import '../../application/use_cases/make_move_use_case.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_over_dialog.dart';

/// Tela principal do jogo.
/// Responsabilidade única: montar a UI e reagir a mudanças do GameController.
/// Toda regra de jogo já foi resolvida nas camadas de domain/application.
class GameScreen extends StatefulWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _keyboardHandler = KeyboardInputHandler();
  final _focusNode = FocusNode();
  GameStatus _lastHandledStatus = GameStatus.playing;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  /// Reage a mudanças de estado do controller — por exemplo, mostrando
  /// o diálogo de fim de jogo apenas uma vez por término de partida.
  void _onControllerChanged() {
    final status = widget.controller.status;
    if (status != GameStatus.playing && status != _lastHandledStatus) {
      _lastHandledStatus = status;
      _showStatusDialog(status);
    }
    if (status == GameStatus.playing) {
      _lastHandledStatus = GameStatus.playing;
    }
    setState(() {});
  }

  void _showStatusDialog(GameStatus status) {
    final isWin = status == GameStatus.won;
    showGameOverDialog(
      context: context,
      title: isWin ? '🎉 Você venceu!' : 'Game Over!',
      content: 'Pontuação: ${widget.controller.score}',
      onPlayAgain: () {
        _lastHandledStatus = GameStatus.playing;
        widget.controller.resetGame();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth.clamp(0.0, 400.0) - 40;
    final controller = widget.controller;

    return Scaffold(
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            final direction = _keyboardHandler.mapKeyEvent(event);
            if (direction != null) controller.handleMove(direction);
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Merge\n Number',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Row(
                          children: [
                            ScoreCardWidget(
                              title: 'SCORE',
                              value: controller.score,
                            ),
                            const SizedBox(width: 8),
                            ScoreCardWidget(
                              title: 'BEST',
                              value: controller.highScore,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '← → ↑ ↓  ou  arraste na tela',
                      style: TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                    const SizedBox(height: 16),
                    GameBoardWidget(
                      board: controller.board,
                      size: boardSize,
                      onSwipe: controller.handleMove,
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      onPressed: controller.resetGame,
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
    );
  }
}
