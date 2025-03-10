import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class DuplicateDialog extends ConsumerWidget {
  final String source;
  final VoidCallback onProceed;

  const DuplicateDialog({
    required this.source,
    required this.onProceed,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void cancel() {
      context.pop();
    }

    void proceedAnyway() {
      context.pop();
      onProceed();
    }

    return AlertDialog.adaptive(
      title: Text(context.s.details_duplicate_dialog_title),
      insetPadding: const EdgeInsets.all(Dimensions.dialogInsetSpacing),
      contentPadding: const EdgeInsets.only(
        left: Dimensions.semiLargeSpacing,
        right: Dimensions.semiLargeSpacing,
        top: Dimensions.semiLargeSpacing,
        bottom: 0,
      ),
      content: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: context.s.details_duplicate_dialog_content_1),
            TextSpan(
              text: source,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: context.s.details_duplicate_dialog_content_2),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(Dimensions.mediumSpacing),
      actions: [
        OutlinedButton(
          onPressed: proceedAnyway,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(Dimensions.semiSmallSpacing),
          ),
          child: Text(context.s.details_duplicate_dialog_action),
        ),
        ElevatedButton(
          onPressed: cancel,
          child: Text(context.s.common_cancel),
        ),
      ],
    );
  }
}
