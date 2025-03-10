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

    final isSignedIn = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.currentUser?.isSignedIn ?? false;
    }));

    final isAnonymous = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.currentUser?.isAnonymous ?? false;
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
          _FeedbackButton(),
          _ThreeDotsMenu(),
          SizedBox(width: Dimensions.largeSpacing),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.largeSpacing),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: Dimensions.mediumSpacing),
          if (isSignedIn)
            const _ProfileContainer()
          else if (isAnonymous)
            const _AnonymousProfileContainer(),
          const SizedBox(height: Dimensions.semiLargeSpacing),
          const _SourceLanguageSettingsTile(),
          const _TargetLanguageSettingsTile(),
          const _OpenNotificationSettingsButton(),
          if (kDebugMode) ...[
            const _GatherNotificationTimeSettingsTile(),
            const _PracticeNotificationTimeSettingsTile(),
          ],
          if (isSignedIn) const _KeepDataSettingsTile(),
          const SizedBox(height: Dimensions.mediumSpacing),
          const _ToggleExperimentalButton(),
          const SizedBox(height: Dimensions.mediumSpacing),
          if (showExperimental) ...[
            const _DisablePracticeTextAnswerSettingsTile(),
            const _EnableCollectionsSettingsTile(),
            const _HideImagesSettingsTile(),
          ],
          const SizedBox(height: Dimensions.extraLargeSpacing),
        ],
      ),
    );
  }
}

class _FeedbackButton extends ConsumerWidget {
  const _FeedbackButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    return InkWell(
      onTap: () => ref.read(notifier).openSurvey(context),
      borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.mediumSpacing,
          vertical: Dimensions.smallSpacing,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: Dimensions.mediumBorderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.feedback_rounded,
              size: Dimensions.semiSmallIconSize,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: Dimensions.smallSpacing),
            Text(
              context.s.settings_feedback,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreeDotsMenu extends ConsumerWidget {
  const _ThreeDotsMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () => ref.read(settingsControllerProvider.notifier).goToBugReport(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bug_report_rounded),
                const SizedBox(width: Dimensions.smallSpacing),
                Text(context.s.report_bug_title),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () => ref.read(settingsControllerProvider.notifier).goToOnboarding(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.description_rounded),
                const SizedBox(width: Dimensions.smallSpacing),
                Text(context.s.onboarding_title),
              ],
            ),
          ),
        ];
      },
    );
  }
}

class _AnonymousProfileContainer extends ConsumerWidget {
  const _AnonymousProfileContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.mediumSpacing,
        vertical: Dimensions.mediumSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            child: InkWell(
              onLongPress: ref.read(notifier).copyId,
              // * GestureDector and AbsorbPointer prevent onTap ripple
              child: GestureDetector(
                onTap: () {},
                child: ExcludeSemantics(
                  child: AbsorbPointer(
                    child: Text(context.s.settings_sign_in_hint),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.semiSmallSpacing),
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              onPressed: () => ref.read(notifier).goToAnonymousAccountLinking(context),
              child: Text(context.s.settings_sign_in_action),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContainer extends ConsumerWidget {
  const _ProfileContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final currentUser = ref.watch(settingsControllerProvider.select((s) {
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
          const _ProfilePicture(),
          const SizedBox(width: Dimensions.mediumSpacing),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentUser.isSignedIn) ...[
                  Text(
                    currentUser.displayName,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  const SizedBox(height: Dimensions.extraSmallSpacing),
                  Text(
                    currentUser.info,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ],
            ),
          ),
          if (currentUser.isSignedIn) ...[
            const SizedBox(width: Dimensions.smallSpacing),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(notifier).signOut(context);
              },
            ),
          ],
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

class _DisablePracticeTextAnswerSettingsTile extends ConsumerWidget {
  const _DisablePracticeTextAnswerSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = settingsControllerProvider.notifier;
    final isTypeAnswerModeDisabled = ref.watch(settingsControllerProvider.select((s) {
      return s.value?.isTypeAnswerModeDisabled ?? false;
    }));

    return _SettingsListTile(
      title: context.s.settings_disable_type_answer_mode,
      subtitle: context.s.settings_disable_type_answer_mode_hint,
      trailing: Switch(
        value: isTypeAnswerModeDisabled,
        onChanged: ref.read(notifier).setIsTypeAnswerModeDisabled,
      ),
    );
  }
}

class _EnableCollectionsSettingsTile extends ConsumerWidget {
  const _EnableCollectionsSettingsTile();

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
