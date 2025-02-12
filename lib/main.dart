import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:log/log.dart';
import 'package:vocabualize/config/themes/theme_config.dart';
import 'package:vocabualize/constants/global.dart';
import 'package:vocabualize/src/features/collections/presentation/screens/collection_screen.dart';
import 'package:vocabualize/src/common/presentation/widgets/start.dart';
import 'package:vocabualize/src/features/home/presentation/screens/home_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/forgot_password_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/sign_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/choose_languages_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:vocabualize/src/features/practice/presentation/screens/practice_screen.dart';
import 'package:vocabualize/src/features/details/presentation/screens/details_screen.dart';
import 'package:vocabualize/src/features/record/presentation/screens/record_screen.dart';
import 'package:vocabualize/src/features/reports/presentation/screens/report_screen.dart';
import 'package:vocabualize/src/common/presentation/screens/language_picker_screen.dart';
import 'package:vocabualize/src/features/settings/presentation/screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Log.hint("App is starting...");
  runApp(const Vocabualize());
}

final resetAllProvidersProvider = Provider<void Function()>((ref) {
  throw UnimplementedError('resetAllProvidersProvider not initialized');
});

class Vocabualize extends StatefulWidget {
  const Vocabualize({super.key});

  @override
  State<Vocabualize> createState() => _VocabualizeState();
}

class _VocabualizeState extends State<Vocabualize> {
  late Key _providerScopeKey;

  @override
  void initState() {
    super.initState();
    _providerScopeKey = UniqueKey();
  }

  void _resetProviderScope() {
    setState(() {
      _providerScopeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _providerScopeKey,
      overrides: [
        resetAllProvidersProvider.overrideWithValue(_resetProviderScope),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('de', ''),
          Locale('es', ''),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeConfig.dark(context),
        darkTheme: ThemeConfig.dark(context),
        debugShowCheckedModeBanner: false,
        navigatorKey: Global.navigatorState,
        initialRoute: Start.routeName,
        routes: {
          Start.routeName: (context) => const Start(),
          OnboardingScreen.routeName: (context) => const OnboardingScreen(),
          WelcomeScreen.routeName: (context) => const WelcomeScreen(),
          SignScreen.routeName: (context) => const SignScreen(),
          ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
          ChooseLanguagesScreen.routeName: (context) => const ChooseLanguagesScreen(),
          LanguagePickerScreen.routeName: (context) => const LanguagePickerScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          RecordScreen.routeName: (context) => const RecordScreen(),
          PracticeScreen.routeName: (context) => const PracticeScreen(),
          DetailsScreen.routeName: (context) => const DetailsScreen(),
          CollectionScreen.routeName: (context) => const CollectionScreen(),
          ReportScreen.routeName: (context) => const ReportScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
