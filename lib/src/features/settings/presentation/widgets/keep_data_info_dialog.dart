import 'package:flutter/material.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class KeepDataInfoDialog extends StatelessWidget {
  const KeepDataInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      insetPadding: const EdgeInsets.all(Dimensions.mediumSpacing),
      title: Text(context.s.settings_keep_data_dialog_title),
      content: Text(context.s.settings_keep_data_dialog_content),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: Text(context.s.common_close),
        ),
      ],
    );
  }
}
