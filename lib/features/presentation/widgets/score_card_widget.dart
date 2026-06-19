import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';

/// Card que exibe um rótulo e um valor (usado para SCORE e BEST).
class ScoreCardWidget extends StatelessWidget {
  final String title;
  final int value;

  const ScoreCardWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: const BoxConstraints(minWidth: 80),
      decoration: BoxDecoration(
        color: AppColors.scoreCardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
