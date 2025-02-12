import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/presentation/extensions/alert_extensions.dart';

class AlertContainer extends StatelessWidget {
  final Alert alert;
  const AlertContainer({required this.alert, super.key});

  @override
  Widget build(BuildContext context) {
    final imageUrl = alert.imageUrl;
    final title = alert.getLocalTitle(context);
    final message = alert.getLocalMessage(context);
    final buttonUrl = alert.buttonUrl;
    return Container(
      padding: const EdgeInsets.all(Dimensions.semiLargeSpacing),
      decoration: BoxDecoration(
        color: alert.getColor(),
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: Dimensions.extraSmallSpacing),
                ],
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (imageUrl != null || buttonUrl != null) ...[
            const SizedBox(width: Dimensions.mediumSpacing),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (imageUrl != null) ...[
                  SizedBox(
                    width: Dimensions.extraLargeSpacing,
                    height: Dimensions.extraLargeSpacing,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
                      child: Image.network("$imageUrl", fit: BoxFit.cover),
                    ),
                  ),
                ],
                if (imageUrl != null && buttonUrl != null) ...[
                  const SizedBox(height: Dimensions.smallSpacing),
                ],
                if (buttonUrl != null) ...[
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => launchUrl(buttonUrl),
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
