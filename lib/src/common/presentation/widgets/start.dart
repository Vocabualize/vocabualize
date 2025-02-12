import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/use_cases/alerts/get_alerts_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/get_current_user_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/notification/init_cloud_notifications_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/notification/init_local_notifications_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/notification/schedule_gather_notification_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/notification/schedule_practice_notification_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_has_seen_language_selection_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_has_seen_onboarding_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_has_seen_language_selection_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_has_seen_onboarding_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/system/get_connection_status_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/blocking_alert_screen.dart';
import 'package:vocabualize/src/common/presentation/screens/loading_screen.dart';
import 'package:vocabualize/src/common/presentation/screens/offline_screen.dart';
import 'package:vocabualize/src/features/home/presentation/screens/home_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/choose_languages_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/verify_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/welcome_screen.dart';

class Start extends ConsumerStatefulWidget {
  static const routeName = "/";
  const Start({super.key});

  @override
  ConsumerState createState() => _StartState();
}

class _StartState extends ConsumerState<Start> {
  @override
  void initState() {
    super.initState();
    _showOnboardingIfNecessary();
  }

  void _showOnboardingIfNecessary() async {
    await ref.read(getHasSeenOnboardingUseCaseProvider)().then((hasSeen) async {
      if (!hasSeen) {
        context.pushNamed(OnboardingScreen.routeName);
        await ref.read(setHasSeenOnboardingUseCaseProvider)(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasConnection = ref.watch(getConnectionStatusUseCaseProvider).when(
          loading: () => null,
          error: (_, __) => false,
          data: (hasConnection) => hasConnection,
        );
    final blockingAlerts = ref.watch(getAlertsUseCaseProvider(AlertPosition.blocking)).when(
          loading: () => null,
          error: (_, __) => <Alert>[],
          data: (blockingAlerts) => blockingAlerts,
        );
    final currentUser = ref.watch(getCurrentUserUseCaseProvider).when(
          loading: () => null,
          error: (_, __) => null,
          data: (AppUser? user) => user,
        );

    if (hasConnection == null || blockingAlerts == null) {
      return const LoadingScreen();
    }

    if (!hasConnection) {
      return const OfflineScreen();
    }

    if (blockingAlerts.isNotEmpty) {
      return BlockingAlertScreen(alert: blockingAlerts.first);
    }

    return switch (currentUser?.verified) {
      true => _HomeScreen(currentUser),
      false => const VerifyScreen(),
      null => const WelcomeScreen(),
    };
  }
}

class _HomeScreen extends ConsumerStatefulWidget {
  final AppUser? user;
  const _HomeScreen(this.user);

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<_HomeScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await ref.read(getHasSeenLanguageSelectionUseCaseProvider)().then((hasSeen) async {
      if (!hasSeen) {
        await _showLanguageSelection();
      }
      _scheduleNotifications();
    });
  }

  Future<void> _showLanguageSelection() async {
    return await context.pushNamed(ChooseLanguagesScreen.routeName).then((_) async {
      await ref.read(setHasSeenLanguageSelectionUseCaseProvider)(true);
    });
  }

  Future<void> _scheduleNotifications() async {
    ref.read(initCloudNotificationsUseCaseProvider)();
    if (!mounted) return;
    await ref.read(initLocalNotificationsUseCaseProvider)().then((_) async {
      if (!mounted) return;
      await ref.read(scheduleGatherNotificationUseCaseProvider)();
      if (!mounted) return;
      await ref.read(schedulePracticeNotificationUseCaseProvider)();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
