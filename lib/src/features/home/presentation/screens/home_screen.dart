import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/asset_path.dart';
import 'package:vocabualize/constants/common_constants.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/constants/tracking_constants.dart';
import 'package:vocabualize/src/common/domain/use_cases/tracking/track_event_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/loading_screen.dart';
import 'package:vocabualize/src/common/presentation/widgets/alert_container.dart';
import 'package:vocabualize/src/features/home/presentation/controllers/home_controller.dart';
import 'package:vocabualize/src/features/home/presentation/extentions/list_extensions.dart';
import 'package:vocabualize/src/features/home/presentation/widgets/collections_section.dart';
import 'package:vocabualize/src/features/home/presentation/widgets/new_vocabularies_section.dart';
import 'package:vocabualize/src/features/home/presentation/widgets/status_card.dart';
import 'package:vocabualize/src/common/presentation/widgets/vocabulary_list_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String routeName = "/Home";

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(trackEventUseCaseProvider)(TrackingConstants.appStart);
  }

  @override
  Widget build(BuildContext context) {
    final provider = homeControllerProvider;

    final alerts = ref.watch(provider.select((s) {
      return s.value?.alerts ?? [];
    }));

    final vocabularies = ref.watch(provider.select((s) {
      return s.value?.vocabularies;
    }));

    final newVocabularies = ref.watch(provider.select((s) {
      return s.value?.newVocabularies ?? [];
    }));

    final tags = ref.watch(provider.select((s) {
      return s.value?.tags ?? [];
    }));

    final areCollectionsEnabled = ref.watch(provider.select((s) {
      return s.value?.areCollectionsEnabled ?? false;
    }));

    if (vocabularies == null) {
      return const LoadingScreen();
    }

    if (vocabularies.isEmpty) {
      return const _HomeEmptyScreen();
    }

    const pageHorizontalPadding = EdgeInsets.symmetric(horizontal: Dimensions.largeSpacing);
    const topSectionTitleSpacing = Dimensions.largeSpacing;
    const bottomSectionTitleSpacing = Dimensions.mediumSpacing;
    return Scaffold(
      floatingActionButton: const _RecordFab(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        restorationId: "homeScreen",
        controller: _scrollController,
        children: [
          ...[
            const SizedBox(height: topSectionTitleSpacing),
            const Row(
              children: [
                Expanded(child: _AppTitle()),
                SizedBox(width: Dimensions.mediumSpacing),
                _StreakButton(),
                _SettingsButton(),
              ],
            ),
            const SizedBox(height: bottomSectionTitleSpacing),
            for (final alert in alerts) ...[
              AlertContainer(alert: alert),
              const SizedBox(height: Dimensions.mediumSpacing),
            ],
            const StatusCard(),
          ].padding(pageHorizontalPadding),
          if (newVocabularies.isNotEmpty) ...[
            const SizedBox(height: topSectionTitleSpacing),
            Padding(
              padding: pageHorizontalPadding,
              child: _SectionTitle(context.s.home_newWords),
            ),
            const SizedBox(height: bottomSectionTitleSpacing),
            const NewVocabulariesSection(),
          ],
          if (areCollectionsEnabled && tags.isNotEmpty) ...[
            const SizedBox(height: topSectionTitleSpacing),
            Padding(
              padding: pageHorizontalPadding,
              child: _SectionTitle(context.s.home_collections_title),
            ),
            const SizedBox(height: bottomSectionTitleSpacing),
            const CollectionsSection(),
          ],
          ...[
            const SizedBox(height: topSectionTitleSpacing),
            _SectionTitle(context.s.home_allWords),
            const SizedBox(height: bottomSectionTitleSpacing),
            const _VocabularyFeed(),
            const SizedBox(height: Dimensions.ultraLargeSpacing),
          ].padding(pageHorizontalPadding),
        ],
      ),
    );
  }
}

class _HomeEmptyScreen extends StatelessWidget {
  const _HomeEmptyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const _RecordFab(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.largeSpacing,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: Dimensions.largeSpacing),
              const Row(
                children: [
                  Expanded(child: _AppTitle()),
                  SizedBox(width: Dimensions.mediumSpacing),
                  _StreakButton(),
                  _SettingsButton(),
                ],
              ),
              // image from assets
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  AssetPath.mascotSearch,
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
              ),
              const Spacer(),
              Text(
                context.s.home_add_first_word,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.ultraLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordFab extends ConsumerStatefulWidget {
  const _RecordFab();

  @override
  ConsumerState<_RecordFab> createState() => _RecordFabState();
}

class _RecordFabState extends ConsumerState<_RecordFab> {
  bool _isExtended = false;

  void _toggleExpansion() {
    setState(() => _isExtended = !_isExtended);
  }

  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: 200);

    final provider = homeControllerProvider;
    final notifier = provider.notifier;

    final areImagesDisabled = ref.watch(provider.select((s) {
      return s.value?.areImagesDisabled ?? false;
    }));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          right: -Dimensions.extraExtraLargeSpacing,
          bottom: -Dimensions.extraExtraLargeSpacing,
          child: AnimatedScale(
            duration: Duration.zero,
            alignment: Alignment.bottomRight,
            scale: _isExtended ? 1 : 0,
            child: AnimatedOpacity(
              duration: animationDuration,
              curve: Curves.easeOut,
              opacity: _isExtended ? 1 : 0,
              child: GestureDetector(
                onTap: _toggleExpansion,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSize(
                    duration: animationDuration,
                    curve: Curves.easeOut,
                    child: SizedBox(
                      height: _isExtended ? null : 0,
                      width: _isExtended ? null : 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!areImagesDisabled) ...[
                            _RecordFabItem(
                              onPressed: () {
                                ref.read(notifier).goToRecordScanScreen(context);
                                _toggleExpansion();
                              },
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: context.s.record_fab_scan,
                            ),
                          ],
                          _RecordFabItem(
                            onPressed: () {
                              ref.read(notifier).speakAndGoToDetails(context);
                              _toggleExpansion();
                            },
                            icon: const Icon(Icons.mic_rounded),
                            label: context.s.record_fab_speak,
                          ),
                          _RecordFabItem(
                            onPressed: () {
                              ref.read(notifier).writeAndGoToDetails(context);
                              _toggleExpansion();
                            },
                            icon: const Icon(Icons.edit_rounded),
                            label: context.s.record_fab_write,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: _toggleExpansion,
                    isExtended: _isExtended,
                    backgroundColor: _isExtended
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
                        : Theme.of(context).colorScheme.primary,
                    icon: AnimatedRotation(
                      turns: _isExtended ? 0.125 : 0,
                      duration: animationDuration,
                      curve: Curves.easeOut,
                      child: const Icon(Icons.add_rounded),
                    ),
                    label: Text(context.s.common_cancel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordFabItem extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  const _RecordFabItem({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      disabledElevation: 0,
      highlightElevation: 0,
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: Dimensions.mediumSpacing),
            icon,
            const SizedBox(width: Dimensions.smallSpacing),
            Text(label),
            const SizedBox(width: Dimensions.mediumSpacing),
          ],
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

class _StreakButton extends ConsumerWidget {
  const _StreakButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(homeControllerProvider.select((s) {
      return s.value?.streak ?? 0;
    }));
    final isStreakActive = ref.watch(homeControllerProvider.select((s) {
      return s.value?.isStreakActive ?? false;
    }));
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(Dimensions.largeBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.semiSmallSpacing,
          vertical: Dimensions.extraSmallSpacing,
        ),
        decoration: BoxDecoration(
          color: isStreakActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.largeBorderRadius),
          border: isStreakActive
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: Dimensions.smallBorderWith,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$streak",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isStreakActive
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(width: Dimensions.extraSmallSpacing),
            Icon(
              Icons.local_fire_department_rounded,
              color: isStreakActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends ConsumerWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = homeControllerProvider.notifier;
    return IconButton(
      onPressed: () {
        ref.read(notifier).showSettings(context);
      },
      icon: const Icon(Icons.settings_rounded),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class _VocabularyFeed extends ConsumerWidget {
  const _VocabularyFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularies = ref.watch(homeControllerProvider.select((s) {
      return s.value?.vocabularies ?? [];
    }));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final vocabulary in vocabularies.reversed) ...[
          VocabularyListTile(vocabulary: vocabulary),
        ],
      ],
    );
  }
}
