import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vocabualize/constants/asset_path.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/constants/notification_constants.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/language_extensions.dart';
import 'package:vocabualize/src/features/home/presentation/screens/home_screen.dart';
import 'package:vocabualize/src/features/settings/presentation/controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  static const String routeName = "${HomeScreen.routeName}/Settings";
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showExperimental = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.showExperimental ?? false;
    }));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(context.s.settings_title),
        ),
        actions: const [
          _BugReportButton(),
          _OnboardingButton(),
          SizedBox(width: Dimensions.largeSpacing),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.largeSpacing,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: Dimensions.mediumSpacing),
            const _ProfileContainer(),
            const SizedBox(height: Dimensions.semiLargeSpacing),
            const _SourceLanguageSettingsTile(),
            const _TargetLanguageSettingsTile(),
            const _OpenNotificationSettingsButton(),
            if (kDebugMode) ...[
              const _GatherNotificationTimeSettingsTile(),
              const _PracticeNotificationTimeSettingsTile(),
            ],
            const _KeepDataSettingsTile(),
            const SizedBox(height: Dimensions.mediumSpacing),
            const _ToggleExperimentalButton(),
            const SizedBox(height: Dimensions.mediumSpacing),
            if (showExperimental) ...[
              const _EnabledCollectionsSettingsTile(),
              const _HideImagesSettingsTile(),
              const _PremiumTranslatorSettingsTile(),
            ],
            const SizedBox(height: Dimensions.extraLargeSpacing),
          ],
        ),
      ),
    );
  }
}

class _BugReportButton extends ConsumerWidget {
  const _BugReportButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    return IconButton(
      onPressed: () => ref.read(notifier).goToBugReport(context),
      icon: const Icon(Icons.bug_report_rounded),
    );
  }
}

class _OnboardingButton extends ConsumerWidget {
  const _OnboardingButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    return IconButton(
      onPressed: () => ref.read(notifier).goToOnboarding(context),
      icon: const Icon(Icons.description_rounded),
    );
  }
}

class _ProfileContainer extends ConsumerWidget {
  const _ProfileContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final currentUser = ref.watch(settingsControllerProvider.select((s) {
      // * If anonymous users should be allowed again, remove the null check
      return s.value?.currentUser ?? const AppUser();
    }));
    return Container(
      padding: const EdgeInsets.all(Dimensions.mediumSpacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // * If anonymous users should be allowed again, uncomment
          // if (currentUser != null) ...[
          const _ProfilePicture(),
          const SizedBox(width: Dimensions.mediumSpacing),
          // ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // * If anonymous users should be allowed again, uncomment
                // if (currentUser != null) ...[
                Text(currentUser.displayName),
                const SizedBox(height: Dimensions.extraSmallSpacing),
                Text(
                  currentUser.info,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
                // * If anonymous users should be allowed again, uncomment
                // ] else ...[
                //   Text(context.s.settings_sign_in_hint),
                //   const SizedBox(height: Dimensions.smallSpacing),
                //   Align(
                //     alignment: Alignment.topRight,
                //     child: ElevatedButton(
                //       onPressed: () => ref.read(notifier).signIn(context),
                //       child: Text(context.s.settings_sign_in_action),
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
          // * If anonymous users should be allowed again, uncomment
          // if (currentUser != null) ...[
          const SizedBox(width: Dimensions.smallSpacing),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(notifier).signOut(context);
            },
          ),
          // ],
        ],
      ),
    );
  }
}

class _ProfilePicture extends ConsumerWidget {
  const _ProfilePicture();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.currentUser;
    }));
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: currentUser?.avatarUrl?.let((url) {
            return CachedNetworkImageProvider(url);
          }),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onPrimary,
          ).takeIf((_) => currentUser?.avatarUrl == null),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: Dimensions.smallSpacing,
            backgroundColor: Colors.white,
            child: switch (currentUser?.provider) {
              AuthProvider.github => SvgPicture.asset(AssetPath.icGithub),
              AuthProvider.google => SvgPicture.asset(AssetPath.icGoogle),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsListTile({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: Text(title),
      subtitle: subtitle?.let((text) {
        return Text(
          text,
          style: TextStyle(color: Theme.of(context).hintColor),
        );
      }),
      trailing: trailing,
    );
  }
}

class _KeepDataSettingsTile extends ConsumerWidget {
  const _KeepDataSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final isKeepDataEnabled = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.isKeepDataEnabled ?? false;
    }));
    return _SettingsListTile(
      title: context.s.settings_keep_data,
      subtitle: context.s.settings_keep_data_hint,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => ref.read(notifier).showKeepDataInfoDialog(context),
            icon: const Icon(Icons.help_rounded),
          ),
          const SizedBox(width: Dimensions.smallSpacing),
          Switch(
            value: isKeepDataEnabled,
            onChanged: ref.read(notifier).setIsKeepDataEnabled,
          ),
        ],
      ),
    );
  }
}

class _SourceLanguageSettingsTile extends ConsumerWidget {
  const _SourceLanguageSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final sourceLanguageName = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.sourceLanguage.localName(context) ?? "";
    }));
    return _SettingsListTile(
      title: context.s.settings_source,
      subtitle: context.s.settings_sourceHint,
      trailing: OutlinedButton(
        onPressed: () async {
          ref.read(notifier).selectSourceLanguage(context);
        },
        child: Text(sourceLanguageName),
      ),
    );
  }
}

class _TargetLanguageSettingsTile extends ConsumerWidget {
  const _TargetLanguageSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final targetLanguageName = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.targetLanguage.localName(context) ?? "";
    }));
    return _SettingsListTile(
      title: context.s.settings_target,
      subtitle: context.s.settings_targetHint,
      trailing: OutlinedButton(
        onPressed: () => ref.read(notifier).selectTargetLanguage(context),
        child: Text(targetLanguageName),
      ),
    );
  }
}

class _ToggleExperimentalButton extends ConsumerWidget {
  const _ToggleExperimentalButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final showExperimental = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.showExperimental ?? false;
    }));
    return ListTile(
      onTap: ref.read(notifier).toggleExperimental,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
      title: Text(
        showExperimental
            ? context.s.settings_experimental_hide
            : context.s.settings_experimental_show,
        textAlign: TextAlign.center,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      trailing: showExperimental
          ? const Icon(Icons.expand_less_rounded)
          : const Icon(Icons.expand_more_rounded),
    );
  }
}

class _EnabledCollectionsSettingsTile extends ConsumerWidget {
  const _EnabledCollectionsSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final areCollectionsEnabled = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.areCollectionsEnabled ?? false;
    }));
    return _SettingsListTile(
      title: context.s.settings_collections,
      subtitle: context.s.settings_collectionsHint,
      trailing: Switch(
        value: areCollectionsEnabled,
        onChanged: ref.read(notifier).setAreCollectionsEnabled,
      ),
    );
  }
}

class _HideImagesSettingsTile extends ConsumerWidget {
  const _HideImagesSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final areImagesDisabled = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.areImagesDisabled ?? false;
    }));
    return _SettingsListTile(
      title: context.s.settings_images,
      subtitle: context.s.settings_imagesHint,
      trailing: Switch(
        value: areImagesDisabled,
        onChanged: ref.read(notifier).setAreImagesDisabled,
      ),
    );
  }
}

class _PremiumTranslatorSettingsTile extends ConsumerWidget {
  const _PremiumTranslatorSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final usePremiumTranslator = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.usePremiumTranslator ?? false;
    }));
    return _SettingsListTile(
      title: context.s.settings_deepl_title,
      subtitle: context.s.settings_deepl_hint,
      trailing: Switch(
        value: usePremiumTranslator,
        onChanged: ref.read(notifier).setUsePremiumTranslator,
      ),
    );
  }
}

class _OpenNotificationSettingsButton extends ConsumerWidget {
  const _OpenNotificationSettingsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    return ListTile(
      contentPadding: const EdgeInsets.only(right: Dimensions.mediumSpacing),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
      onTap: ref.read(notifier).openNotificationSettings,
      title: Text(context.s.settings_notifications_title),
      subtitle: Text(
        context.s.settings_notifications_hint,
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      trailing: const Icon(Icons.open_in_new_rounded),
    );
  }
}

class _GatherNotificationTimeSettingsTile extends ConsumerWidget {
  const _GatherNotificationTimeSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final time = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.gatherNotificationTime;
    }));
    final hour = time?.hour ?? NotificationConstants.gatherNotificationTimeHour;
    final minute = time?.minute ?? NotificationConstants.gatherNotificationTimeMinute;
    return _SettingsListTile(
      title: context.s.settings_gather_title,
      subtitle: context.s.settings_gather_hint,
      trailing: OutlinedButton(
        onPressed: () => ref.read(notifier).selectGatherNotificationTime(context),
        child: Text(
          "${hour.toString().padLeft(2, '0')}:"
          "${minute.toString().padLeft(2, '0')}",
        ),
      ),
    );
  }
}

class _PracticeNotificationTimeSettingsTile extends ConsumerWidget {
  const _PracticeNotificationTimeSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final time = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.practiceNotificationTime;
    }));
    final hour = time?.hour ?? NotificationConstants.practiceNotificationTimeHour;
    final minute = time?.minute ?? NotificationConstants.practiceNotificationTimeMinute;
    return _SettingsListTile(
      title: context.s.settings_practice_title,
      subtitle: context.s.settings_practice_hint,
      trailing: OutlinedButton(
        onPressed: () => ref.read(notifier).selectPracticeNotificationTime(context),
        child: Text(
          "${hour.toString().padLeft(2, '0')}:"
          "${minute.toString().padLeft(2, '0')}",
        ),
      ),
    );
  }
}
