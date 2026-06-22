import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/core/app_strings.dart';

/// Mostra o diálogo de fim de jogo (vitória ou derrota).
/// É uma função utilitária de UI, sem estado próprio.
void showGameOverDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onPlayAgain,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPlayAgain();
          },
          child: const Text(AppStrings.playAgain),
        ),
      ],
    ),
  );
}
