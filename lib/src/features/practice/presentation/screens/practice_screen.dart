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
import 'package:vocabualize/src/features/practice/domain/extensions/string_extensions.dart';
import 'package:vocabualize/src/features/practice/domain/use_cases/get_difficulty_from_text_answer_use_case.dart';
import 'package:vocabualize/src/features/practice/presentation/controllers/practice_controller.dart';
import 'package:vocabualize/src/common/domain/entities/answer.dart';
import 'package:vocabualize/src/features/practice/presentation/widgets/solution_diff_text.dart';

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

    if (isDone == null || doneCount == null || initialVocabularyCount == null) {
      return LoadingScreen(onCancel: context.pop);
    }

    if (isDone) {
      return _PracticeDoneScreen(tag);
    }

    final isSolutionShown = ref.watch(provider.select((state) {
      return state.valueOrNull?.isSolutionShown ?? false;
    }));

    final shouldAskForTextAnswer = ref.watch(provider.select((state) {
      return state.valueOrNull?.shouldAskForTextAnswer ?? false;
    }));

    final areImagesDisabled = ref.watch(provider.select((state) {
      return state.valueOrNull?.areImagesDisabled ?? false;
    }));

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: Dimensions.largeSpacing),
                      _ProgressBar(tag),
                      const SizedBox(height: Dimensions.mediumSpacing),
                      if (areImagesDisabled)
                        const SizedBox(height: Dimensions.extraExtraLargeSpacing),
                      _MultilingualLabel(tag),
                      const SizedBox(height: Dimensions.semiSmallSpacing),
                      _ImageOrSolutionBox(tag),
                      const SizedBox(height: Dimensions.largeSpacing),
                      _SourceText(tag),
                      const SizedBox(height: Dimensions.mediumSpacing),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      if (isSolutionShown) _RateButtons(tag),
                      const SizedBox(height: Dimensions.mediumSpacing),
                      if (!isSolutionShown && shouldAskForTextAnswer)
                        _AnswerTextField(tag)
                      else
                        _ShowSolutionOrForgotButton(tag),
                      const SizedBox(height: Dimensions.extraExtraLargeSpacing)
                    ],
                  ),
                )
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
    final givenAnswer = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentAnswer;
    }));
    final articles = ref.watch(provider.select((state) {
      return state.valueOrNull?.possibleArticles ?? {};
    }));
    final textAnswerDifficulty = ref.watch(getDifficultyFromTextAnswerProvider)(
      givenAnswer,
      currentVocabularyTarget,
      possibleArticles: articles,
    );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
        border: Border.all(
          color: switch (textAnswerDifficulty) {
            Answer.forgot => LevelPalette.novice,
            Answer.hard => LevelPalette.beginner,
            Answer.good => LevelPalette.advanced,
            Answer.easy => LevelPalette.expert,
            null => Colors.transparent,
          },
          width: Dimensions.largeBorderWidth,
        ),
        borderRadius: BorderRadius.circular(Dimensions.semiLargeBorderRadius),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SolutionDiffText(
                givenAnswerText: givenAnswer ?? currentVocabularyTarget,
                solutionText: currentVocabularyTarget,
                maxLines: 7,
              ),
            ),
            const SizedBox(width: Dimensions.smallSpacing),
            _AudioButton(tag),
          ],
        ),
      ),
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
    return Row(
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
    final provider = practiceControllerProvider(tag);
    final notifier = provider.notifier;
    final givenAnswer = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentAnswer;
    }));
    final currentVocabularyTarget = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentVocabulary?.target ?? "";
    }));
    final articles = ref.watch(provider.select((state) {
      return state.valueOrNull?.possibleArticles ?? {};
    }));
    final textAnswerDifficulty = ref.watch(getDifficultyFromTextAnswerProvider)(
      givenAnswer,
      currentVocabularyTarget,
      possibleArticles: articles,
    );
    // TODO: Refactor isEnabled logic for practice rate buttons (and move)
    final isEnabled = switch (textAnswerDifficulty) {
      null => true,
      Answer.forgot => [Answer.forgot].contains(answer),
      Answer.hard => [Answer.forgot, Answer.hard].contains(answer),
      Answer.good => [Answer.hard, Answer.good].contains(answer),
      Answer.easy => [Answer.good, Answer.easy].contains(answer),
    };
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.semiSmallSpacing,
        ),
        backgroundColor: color,
      ),
      onPressed: isEnabled
          ? () {
              ref.read(notifier).answerCurrent(answer);
              ref.read(trackEventUseCaseProvider)(switch (answer) {
                Answer.forgot => TrackingConstants.practiceAnswerForgot,
                Answer.hard => TrackingConstants.practiceAnswerHard,
                Answer.good => TrackingConstants.practiceAnswerGood,
                Answer.easy => TrackingConstants.practiceAnswerEasy,
              });
            }
          : null,
      child: Text(text),
    );
  }
}

class _AnswerTextField extends ConsumerStatefulWidget {
  final Tag? tag;
  const _AnswerTextField(this.tag);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __AnswerTextFieldState();
}

class __AnswerTextFieldState extends ConsumerState<_AnswerTextField> {
  final _answerTextController = TextEditingController();
  bool _isAnswerTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _answerTextController.addListener(() {
      setState(() {
        _isAnswerTextEmpty = _answerTextController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _answerTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = practiceControllerProvider(widget.tag);

    // * Give the first article to reduce frustration if forgotten
    // TODO: Move addFirstArticleIfEmpty logic to PracticeController
    void addFirstArticleIfEmpty() async {
      if (!_isAnswerTextEmpty) return;
      final articles = ref.read(provider.select((state) {
        return state.valueOrNull?.possibleArticles ?? {};
      }));
      _answerTextController.text = ref.read(provider.select((state) {
        return state.valueOrNull?.currentVocabulary?.target.findFirstArticle(articles) ?? "";
      }));
    }

    void hideKeyboard() {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    return TextField(
      controller: _answerTextController,
      onTap: addFirstArticleIfEmpty,
      onTapOutside: (_) => hideKeyboard(),
      onEditingComplete: hideKeyboard,
      onSubmitted: (answer) {
        ref.read(provider.notifier).showSolution(_answerTextController.text);
      },
      autocorrect: false,
      autofillHints: null,
      enableSuggestions: false,
      decoration: InputDecoration(
        label: Text(context.s.practice_answer_text_field_label),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: _isAnswerTextEmpty
            ? null
            : IconButton(
                onPressed: () {
                  ref.read(provider.notifier).showSolution(_answerTextController.text);
                },
                icon: const Icon(Icons.done_rounded),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.smallSpacing),
        ),
      ),
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
      onPressed: () => ref.read(notifier).showSolution(null),
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
    final provider = practiceControllerProvider(tag);
    final notifier = provider.notifier;
    final givenAnswer = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentAnswer;
    }));
    final currentVocabularyTarget = ref.watch(provider.select((state) {
      return state.valueOrNull?.currentVocabulary?.target ?? "";
    }));
    final articles = ref.watch(provider.select((state) {
      return state.valueOrNull?.possibleArticles ?? {};
    }));
    final textAnswerDifficulty = ref.watch(getDifficultyFromTextAnswerProvider)(
      givenAnswer,
      currentVocabularyTarget,
      possibleArticles: articles,
    );
    // TODO: Refactor isEnabled logic for practice forgot button (and combine with rate buttons)
    final isEnabled = [Answer.forgot, Answer.hard, null].contains(textAnswerDifficulty);
    return OutlinedButton(
      onPressed: isEnabled
          ? () {
              ref.read(notifier).answerCurrent(Answer.forgot);
              ref.read(trackEventUseCaseProvider)(TrackingConstants.practiceAnswerForgot);
            }
          : null,
      child: Text(context.s.practice_rating_didntKnowButton),
    );
  }
}
