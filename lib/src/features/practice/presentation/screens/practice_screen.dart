import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/config/themes/level_palette.dart';
import 'package:vocabualize/constants/asset_path.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/constants/tracking_constants.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/use_cases/tracking/track_event_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/tracking/track_practice_iteration_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/vocabulary_image_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/loading_screen.dart';
import 'package:vocabualize/src/features/home/presentation/screens/home_screen.dart';
import 'package:vocabualize/src/features/practice/presentation/controllers/practice_controller.dart';
import 'package:vocabualize/src/common/domain/entities/answer.dart';

class PracticeScreenArguments {
  final Tag tag;
  PracticeScreenArguments({required this.tag});
}

class PracticeScreen extends ConsumerStatefulWidget {
  static const String routeName = "${HomeScreen.routeName}/Practice";
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  Tag? tag;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as PracticeScreenArguments?;
      setState(() {
        tag = arguments?.tag;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = practiceControllerProvider(tag);

    final isDone = ref.watch(provider.select((state) {
      return state.value?.isDone;
    }));

    final doneCount = ref.watch(provider.select((state) {
      return state.value?.doneCount;
    }));

    final initialVocabularyCount = ref.watch(provider.select((state) {
      return state.value?.initialVocabularyCount;
    }));

    if (isDone == null || initialVocabularyCount == null || doneCount == null) {
      return LoadingScreen(onCancel: context.pop);
    }

    if (isDone) {
      return _PracticeDoneScreen(tag);
    }

    return PopScope(
      onPopInvoked: (_) {
        if (initialVocabularyCount > 0) {
          ref.read(trackPracticeIterationUseCaseProvider)(
            practicedCount: doneCount,
            dueCount: initialVocabularyCount,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.extraLargeSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Dimensions.largeSpacing),
                _ProgressBar(tag),
                const Spacer(),
                _MultilingualLabel(tag),
                const SizedBox(height: Dimensions.semiSmallSpacing),
                _ImageOrSolutionBox(tag),
                const SizedBox(height: Dimensions.largeSpacing),
                _SourceText(tag),
                const Spacer(),
                _RateButtons(tag),
                const SizedBox(height: Dimensions.mediumSpacing),
                _ShowSolutionOrForgotButton(tag),
                const SizedBox(height: Dimensions.extraExtraLargeSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeDoneScreen extends ConsumerWidget {
  final Tag? tag;
  const _PracticeDoneScreen(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.largeSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              AssetPath.mascotHanging,
              frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  offset: frame == null ? const Offset(0, -1) : Offset.zero,
                  child: child,
                );
              },
            ),
            const Spacer(),
            Text(
              context.s.practice_done_title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.mediumSpacing),
            Text(
              context.s.practice_done_subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
            _PracticeDoneButton(tag),
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
          ],
        ),
      ),
    );
  }
}

class _PracticeDoneButton extends ConsumerWidget {
  final Tag? tag;

  const _PracticeDoneButton(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final notifier = provider.notifier;
    final initialVocabularyCount = ref.watch(provider.select((state) {
      return state.valueOrNull?.initialVocabularyCount ?? 0;
    }));
    final doneCount = ref.watch(provider.select((state) {
      return state.valueOrNull?.doneCount ?? 0;
    }));
    return ElevatedButton(
      onPressed: () {
        ref.read(notifier).close(context);
        if (initialVocabularyCount > 0) {
          ref.read(trackPracticeIterationUseCaseProvider)(
            practicedCount: doneCount,
            dueCount: initialVocabularyCount,
          );
        }
      },
      child: Text(context.s.practice_done_action),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  final Tag? tag;
  const _ProgressBar(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final notifier = provider.notifier;
    final doneCount = ref.watch(provider.select((state) {
      return state.valueOrNull?.doneCount ?? 0;
    }));
    final initialVocabularyCount = ref.watch(provider.select((state) {
      return state.valueOrNull?.initialVocabularyCount ?? 0;
    }));
    final String countText = "$doneCount / $initialVocabularyCount";

    return Row(
      children: [
        IconButton(
          onPressed: () => ref.read(notifier).close(context),
          icon: const Icon(Icons.close_rounded),
        ),
        const SizedBox(width: Dimensions.mediumSpacing),
        Expanded(
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(Dimensions.smallSpacing),
            value: doneCount / initialVocabularyCount,
            minHeight: Dimensions.semiSmallSpacing,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(width: Dimensions.semiLargeSpacing),
        Text(
          countText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: Dimensions.mediumSpacing),
      ],
    );
  }
}

class _MultilingualLabel extends ConsumerWidget {
  final Tag? tag;
  const _MultilingualLabel(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final notifier = provider.notifier;
    final isMultilingual = ref.watch(provider.select((state) {
      return state.valueOrNull?.isMultilingual ?? false;
    }));
    if (!isMultilingual) {
      return const SizedBox.shrink();
    }
    return FutureBuilder(
      future: ref.watch(notifier).getMultilingualLabel(),
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? "",
          style: TextStyle(
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

class _ImageOrSolutionBox extends ConsumerWidget {
  final Tag? tag;
  const _ImageOrSolutionBox(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final areImagesDisabled = ref.watch(provider.select((state) {
      return state.valueOrNull?.areImagesDisabled ?? false;
    }));
    final isSolutionShown = ref.watch(provider.select((state) {
      return state.valueOrNull?.isSolutionShown ?? false;
    }));
    return Stack(
      children: [
        if (!areImagesDisabled) ...[
          AspectRatio(
            aspectRatio: 1 / 1,
            child: _ImageBox(tag),
          ),
        ],
        if (isSolutionShown) ...[
          AspectRatio(
            aspectRatio: 1 / 1,
            child: _Solution(tag),
          ),
        ],
      ],
    );
  }
}

class _ImageBox extends ConsumerWidget {
  final Tag? tag;
  const _ImageBox(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final currentVocabularyImage = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentVocabulary?.image;
    }));
    if (currentVocabularyImage == null) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.semiLargeSpacing),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: currentVocabularyImage.getImageProvider(
            size: ImageSize.medium,
          ),
        ),
      ),
    );
  }
}

class _Solution extends ConsumerWidget {
  final Tag? tag;
  const _Solution(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final currentVocabularyTarget = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentVocabulary?.target ?? "";
    }));
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
        borderRadius: BorderRadius.circular(Dimensions.semiLargeBorderRadius),
      ),
      child: Center(
          child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              currentVocabularyTarget,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 7,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: Dimensions.smallSpacing),
          _AudioButton(tag),
        ],
      )),
    );
  }
}

class _AudioButton extends ConsumerStatefulWidget {
  final Tag? tag;
  const _AudioButton(this.tag);

  @override
  ConsumerState<_AudioButton> createState() => __AudioButtonState();
}

class __AudioButtonState extends ConsumerState<_AudioButton> {
  bool hasPressedOnce = false;

  @override
  Widget build(BuildContext context) {
    final notifier = practiceControllerProvider(widget.tag).notifier;
    return IconButton(
      onPressed: () {
        ref.read(notifier).readOutCurrent();
        if (!hasPressedOnce) {
          hasPressedOnce = true;
          ref.read(trackEventUseCaseProvider)(TrackingConstants.practiceAudio);
        }
      },
      icon: const Icon(
        Icons.volume_up_rounded,
        size: Dimensions.largeIconSize,
      ),
    );
  }
}

class _SourceText extends ConsumerWidget {
  final Tag? tag;
  const _SourceText(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final currentVocabularySource = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentVocabulary?.source ?? "";
    }));
    return Text(
      currentVocabularySource,
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

class _RateButtons extends ConsumerWidget {
  final Tag? tag;
  const _RateButtons(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final isSolutionShown = ref.watch(provider.select((state) {
      return state.valueOrNull?.isSolutionShown ?? false;
    }));
    return Opacity(
      opacity: isSolutionShown ? 1 : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _RateButton(
              tag,
              answer: Answer.hard,
              color: LevelPalette.beginner,
              text: context.s.practice_rating_hardButton,
            ),
          ),
          const SizedBox(width: Dimensions.semiSmallSpacing),
          Expanded(
            child: _RateButton(
              tag,
              answer: Answer.good,
              color: LevelPalette.advanced,
              text: context.s.practice_rating_goodButton,
            ),
          ),
          const SizedBox(width: Dimensions.semiSmallSpacing),
          Expanded(
            child: _RateButton(
              tag,
              answer: Answer.easy,
              color: LevelPalette.expert,
              text: context.s.practice_rating_easyButton,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateButton extends ConsumerWidget {
  final Tag? tag;
  final Answer answer;
  final Color color;
  final String text;
  const _RateButton(
    this.tag, {
    required this.answer,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = practiceControllerProvider(tag).notifier;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.semiSmallSpacing,
        ),
        backgroundColor: color,
      ),
      onPressed: () {
        ref.read(notifier).answerCurrent(answer);
        ref.read(trackEventUseCaseProvider)(switch (answer) {
          Answer.forgot => TrackingConstants.practiceAnswerForgot,
          Answer.hard => TrackingConstants.practiceAnswerHard,
          Answer.good => TrackingConstants.practiceAnswerGood,
          Answer.easy => TrackingConstants.practiceAnswerEasy,
        });
      },
      child: Text(text),
    );
  }
}

class _ShowSolutionOrForgotButton extends ConsumerWidget {
  final Tag? tag;
  const _ShowSolutionOrForgotButton(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = practiceControllerProvider(tag);
    final isSolutionShown = ref.watch(provider.select((state) {
      return state.valueOrNull?.isSolutionShown ?? false;
    }));

    if (isSolutionShown) {
      return _ForgotButton(tag);
    } else {
      return _ShowSolutionButton(tag);
    }
  }
}

class _ShowSolutionButton extends ConsumerWidget {
  final Tag? tag;
  const _ShowSolutionButton(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = practiceControllerProvider(tag).notifier;
    return ElevatedButton(
      onPressed: ref.read(notifier).showSolution,
      child: Text(
        context.s.practice_solutionButton,
      ),
    );
  }
}

class _ForgotButton extends ConsumerWidget {
  final Tag? tag;
  const _ForgotButton(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = practiceControllerProvider(tag).notifier;
    return OutlinedButton(
      onPressed: () {
        ref.read(notifier).answerCurrent(Answer.forgot);
        ref.read(trackEventUseCaseProvider)(TrackingConstants.practiceAnswerForgot);
      },
      child: Text(
        context.s.practice_rating_didntKnowButton,
        style: const TextStyle(color: LevelPalette.novice),
      ),
    );
  }
}
