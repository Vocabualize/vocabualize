import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class AccountLinkingFailedDialog extends StatelessWidget {
  const AccountLinkingFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(context.s.settings_account_linking_failed_dialog_title),
      content: Text(context.s.settings_account_linking_failed_dialog_content),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: Text(context.s.common_okay),
        ),
      ],
    );
  }
}
