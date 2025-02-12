import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/presentation/extensions/alert_extensions.dart';

class BlockingAlertScreen extends StatelessWidget {
  final Alert alert;
  const BlockingAlertScreen({required this.alert, super.key});

  @override
  Widget build(BuildContext context) {
    final imageUrl = alert.imageUrl;
    final title = alert.getLocalTitle(context);
    final message = alert.getLocalMessage(context);
    final buttonLabel = alert.buttonLabel;
    final buttonUrl = alert.buttonUrl;
    return Scaffold(
      backgroundColor: alert.getColor(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.largeSpacing,
          vertical: Dimensions.largeSpacing,
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(Dimensions.semiLargeSpacing),
            children: [
              if (imageUrl != null) ...[
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
                    child: Image.network("$imageUrl", fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: Dimensions.semiLargeSpacing),
              ],
              if (title != null) ...[
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: Dimensions.smallSpacing),
              ],
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (buttonUrl != null) ...[
                const SizedBox(height: Dimensions.largeSpacing),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  onPressed: () => launchUrl(buttonUrl),
                  child: Text(
                    buttonLabel ?? "Test",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
