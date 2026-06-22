import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_merge_puzzle/features/application/use_cases/make_move_use_case.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';
import 'package:number_merge_puzzle/features/core/app_dimensions.dart';
import 'package:number_merge_puzzle/features/core/app_strings.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_cubit.dart';
import 'package:number_merge_puzzle/features/presentation/cubit/game_state.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/game_board_widget.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/game_over_dialog.dart';
import 'package:number_merge_puzzle/features/presentation/widgets/how_to_play_dialog.dart';
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
      title: isWin ? AppStrings.winTitle : AppStrings.gameOverTitle,
      content: '${AppStrings.scorePrefix}: $score',
      onPlayAgain: () => context.read<GameCubit>().resetGame(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize =
        screenWidth.clamp(
          AppDimensions.minBoardSize,
          AppDimensions.maxBoardSize,
        ) -
        AppDimensions.boardHorizontalMargin;

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
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.maxContentWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BlocBuilder reconstrói SÓ esse trecho quando o estado muda.
                      BlocBuilder<GameCubit, GameState>(
                        builder: (context, state) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppDimensions
                                        .headerTitleVerticalPadding,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: AppDimensions.titleFontSize,
                                          letterSpacing:
                                              AppDimensions.titleLetterSpacing,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: AppStrings.gameTitleLight,
                                            style: TextStyle(
                                              fontWeight: FontWeight
                                                  .w200, // Fino e elegante
                                              color: AppColors.titleLightText,
                                            ),
                                          ),
                                          TextSpan(
                                            text: AppStrings.gameTitleStrong,
                                            style: TextStyle(
                                              fontWeight: FontWeight
                                                  .w800, // Grosso e marcante
                                              color: AppColors.titleStrongText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: AppDimensions.headerTitleScoreSpacing,
                              ),
                              Row(
                                children: [
                                  ScoreCardWidget(
                                    title: AppStrings.scoreLabel,
                                    value: state.score,
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.compactSpacing,
                                  ),
                                  ScoreCardWidget(
                                    title: AppStrings.bestScoreLabel,
                                    value: state.highScore,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      const Text(
                        AppStrings.inputHint,
                        style: TextStyle(
                          fontSize: AppDimensions.hintFontSize,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
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
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () =>
                                context.read<GameCubit>().resetGame(),
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: AppDimensions.refreshIconSize,
                            ),
                            color: Colors.white70,
                          ),
                          const SizedBox(width: AppDimensions.compactSpacing),
                          IconButton(
                            onPressed: () => showHowToPlayDialog(context),
                            icon: const Icon(
                              Icons.info_outline,
                              size: AppDimensions.actionIconSize,
                            ),
                            color: Colors.white70,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.sectionSpacing,
                        ),
                        child: Text(
                          AppStrings.developerCredit,
                          style: TextStyle(
                            fontSize:
                                AppDimensions.compactDeveloperCreditFontSize,
                            fontWeight: FontWeight.w200, // Fonte ultra fina
                            letterSpacing:
                                AppDimensions.developerCreditLetterSpacing,
                            color: AppColors.developerCreditText.withValues(
                              alpha: AppColors.developerCreditTextOpacity,
                            ),
                          ),
                        ),
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
