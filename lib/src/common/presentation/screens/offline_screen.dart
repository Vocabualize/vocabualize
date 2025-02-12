import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:vocabualize/constants/asset_path.dart';
import 'package:vocabualize/constants/common_constants.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void showWhyDialog() {
      context.showDialog(const _WhyDialog());
    }

    void openInternetSettings() async {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = androidInfo.version.sdkInt;
      if (androidVersion >= 29) {
        // * AppSettingsPanels only work on Android, and only on >=10
        // If minSdkVersion is high enough, we can remove this statement
        // + perhaps, the DeviceInfoPlugin as well
        AppSettings.openAppSettingsPanel(AppSettingsPanelType.internetConnectivity);
      } else {
        AppSettings.openAppSettings(type: AppSettingsType.wifi);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.largeSpacing,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Dimensions.largeSpacing),
              Row(
                children: [
                  const Expanded(child: _AppTitle()),
                  IconButton(
                    icon: const Icon(Icons.help_rounded),
                    onPressed: showWhyDialog,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.mediumSpacing),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
              ),
              const Spacer(),
              Image.asset(
                AssetPath.mascotOffline,
                height: (MediaQuery.of(context).size.height * 0.4),
                frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: frame == null ? 0 : 1,
                    child: child,
                  );
                },
              ),
              const Spacer(),
              Text(
                context.s.offline_hint,
                textAlign: TextAlign.center,
              ),
              if (Platform.isAndroid) ...[
                const SizedBox(height: Dimensions.largeSpacing),
                OutlinedButton(
                  onPressed: openInternetSettings,
                  child: Text(context.s.offline_internet_settings_button),
                ),
              ],
              const SizedBox(height: Dimensions.extraExtraLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Text(
        CommonConstants.appName,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}

class _WhyDialog extends StatelessWidget {
  const _WhyDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.mediumSpacing,
      ),
      title: Text(context.s.offline_info_title),
      content: Text(
        context.s.offline_info_description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            context.s.common_okay,
          ),
        ),
      ],
    );
  }
}
