import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class ReplaceVocabularyDialog extends StatelessWidget {
  const ReplaceVocabularyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    void cancel() {
      context.pop(false);
    }

    void replace() {
      context.pop(true);
    }

    return AlertDialog.adaptive(
      title: Text(context.s.details_replace_dialog_title),
      content: Text(context.s.details_replace_dialog_content),
      actions: [
        OutlinedButton(
          onPressed: () => cancel(),
          child: Text(context.s.common_no),
        ),
        ElevatedButton(
          onPressed: () => replace(),
          child: Text(context.s.details_replace_dialog_action),
        ),
      ],
    );
  }
}
