import 'package:flutter/material.dart';
import 'package:number_merge_puzzle/features/core/app_dimensions.dart';
import 'package:number_merge_puzzle/features/core/app_strings.dart';

void showHowToPlayDialog(BuildContext context) {
  showDialog(context: context, builder: (_) => const HowToPlayDialog());
}

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.howToPlayTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final step in AppStrings.howToPlaySteps) ...[
            Text('• $step'),
            SizedBox(height: AppDimensions.dialogContentSpacing),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.howToPlayClose),
        ),
      ],
    );
  }
}
