import 'package:flutter/material.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class ErrorPlaceholder extends StatelessWidget {
  const ErrorPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.smallSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: Dimensions.largeIconSize,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: Dimensions.smallSpacing),
          Text(context.s.common_error),
        ],
      ),
    );
  }
}
