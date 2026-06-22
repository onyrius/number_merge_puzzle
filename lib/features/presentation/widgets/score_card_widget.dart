import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/core/app_colors.dart';
import 'package:number_merge_puzzle/features/core/app_dimensions.dart';

/// Card que exibe um rótulo e um valor (usado para SCORE e BEST).
class ScoreCardWidget extends StatelessWidget {
  final String title;
  final int value;

  const ScoreCardWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.scoreCardHorizontalPadding,
        vertical: AppDimensions.scoreCardVerticalPadding,
      ),
      constraints: const BoxConstraints(
        minWidth: AppDimensions.scoreCardMinWidth,
      ),
      decoration: BoxDecoration(
        color: AppColors.scoreCardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.scoreCardRadius),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppDimensions.scoreTitleFontSize,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.compactSpacing / 2),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: AppDimensions.scoreValueFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
