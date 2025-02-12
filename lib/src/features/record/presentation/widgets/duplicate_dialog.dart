import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/widgets/start.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/features/details/presentation/screens/details_screen.dart';

class DuplicateDialog extends ConsumerWidget {
  final Vocabulary vocabulary;

  const DuplicateDialog({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void cancel() {
      context.popUntilNamed(Start.routeName);
    }

    void proceedAnyway() {
      context.pushNamed(
        DetailsScreen.routeName,
        arguments: DetailsScreenArguments(vocabulary: vocabulary),
      );
    }

    return AlertDialog.adaptive(
      title: Text(context.s.details_duplicate_dialog_title),
      content: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: context.s.details_duplicate_dialog_content_1),
            TextSpan(
              text: "  '${vocabulary.source}'  ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: context.s.details_duplicate_dialog_content_2),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => cancel(),
          child: Text(context.s.common_cancel),
        ),
        ElevatedButton(
          onPressed: () => proceedAnyway(),
          child: Text(context.s.details_duplicate_dialog_action),
        ),
      ],
    );
  }
}
