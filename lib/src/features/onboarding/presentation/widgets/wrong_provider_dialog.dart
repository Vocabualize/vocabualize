import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/extensions/string_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class WrongProviderDialog extends StatelessWidget {
  final AuthProvider linkedProvider;
  const WrongProviderDialog({
    required this.linkedProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(context.s.onboarding_sign_failed_title),
      content: Text(
        context.s.onboarding_sign_failed_provider_description(
          linkedProvider.name.firstToUppercase(),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text(context.s.common_okay),
        ),
      ],
    );
  }
}
