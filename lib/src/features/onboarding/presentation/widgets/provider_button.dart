import 'package:flutter/material.dart';
import 'package:vocabualize/constants/dimensions.dart';

class ProviderButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget icon;
  final String title;
  final bool isLoading;

  const ProviderButton({
    required this.onPressed,
    required this.icon,
    required this.title,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.only(
          left: Dimensions.mediumSpacing,
          right: Dimensions.mediumSpacing,
          top: Dimensions.mediumSpacing,
          bottom: Dimensions.mediumSpacing,
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: Dimensions.mediumSpacing),
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              title,
              style: TextStyle(color: Colors.blueGrey[800]),
            ),
          ),
          if (isLoading)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 3,
              ),
            ),
        ],
      ),
    );
  }
}
