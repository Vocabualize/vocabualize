import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/level.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/use_cases/language/read_out_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_collections_enabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/tag/get_tags_by_ids_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/vocabulary_image_extensions.dart';
import 'package:vocabualize/src/features/details/presentation/screens/details_screen.dart';
import 'package:vocabualize/src/features/home/presentation/extentions/vocabulary_extensions.dart';

class VocabularyInfoDialog extends ConsumerWidget {
  final Vocabulary vocabulary;

  const VocabularyInfoDialog({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog.adaptive(
      title: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LevelIndicator(level: vocabulary.level),
            const SizedBox(width: Dimensions.semiSmallSpacing),
            Flexible(
              fit: FlexFit.tight,
              child: _SourceTargetColumn(vocabulary: vocabulary),
            ),
            _ReadOutButton(vocabulary: vocabulary),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ref.watch(getAreImagesDisabledUseCaseProvider).maybeWhen(
                orElse: () => const SizedBox.shrink(),
                data: (areImagesDisabled) {
                  if (areImagesDisabled || vocabulary.image is FallbackImage) {
                    return const SizedBox.shrink();
                  }
                  return Flexible(
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: _ImageBox(image: vocabulary.image),
                    ),
                  );
                },
              ),
          ...ref.watch(getAreCollectionsEnabledUseCaseProvider).maybeWhen(
                orElse: () => [],
                data: (areCollectionsEnabled) {
                  if (!areCollectionsEnabled) return [];
                  return [
                    const SizedBox(height: Dimensions.mediumSpacing),
                    _TagsWrap(tagIds: vocabulary.tagIds),
                  ];
                },
              ),
          const SizedBox(height: Dimensions.mediumSpacing),
          _DatesInformationRow(vocabulary: vocabulary),
        ],
      ),
      actions: [
        Row(
          children: [
            _EditButton(vocabulary: vocabulary),
            const SizedBox(width: Dimensions.mediumSpacing),
            const _CloseButton(),
          ],
        )
      ],
    );
  }
}

class _LevelIndicator extends StatelessWidget {
  final Level level;
  const _LevelIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      width: Dimensions.extraSmallSpacing,
      decoration: BoxDecoration(
        color: level.color,
        borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
      ),
    );
  }
}

class _SourceTargetColumn extends StatelessWidget {
  final Vocabulary vocabulary;
  const _SourceTargetColumn({required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vocabulary.target,
          style: Theme.of(context).textTheme.headlineSmall,
          maxLines: 7,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          vocabulary.source,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ReadOutButton extends ConsumerWidget {
  final Vocabulary vocabulary;
  const _ReadOutButton({required this.vocabulary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> readOut() async {
      await ref.read(readOutUseCaseProvider)(vocabulary);
    }

    return IconButton(
      onPressed: readOut,
      icon: const Icon(Icons.volume_up_rounded),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final VocabularyImage image;
  const _ImageBox({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      clipBehavior: Clip.hardEdge,
      child: image.getImage(
        fit: BoxFit.cover,
        size: ImageSize.large,
      ),
    );
  }
}

class _TagsWrap extends ConsumerWidget {
  final List<String> tagIds;
  const _TagsWrap({required this.tagIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTags = ref.watch(getTagsByIdsUseCaseProvider(tagIds));
    return asyncTags.when(
      loading: () => const SizedBox(),
      error: (error, stackStrace) => const SizedBox(),
      data: (List<Tag> tags) {
        return Wrap(
          spacing: Dimensions.smallSpacing,
          runSpacing: -Dimensions.smallSpacing,
          children: tags.map((tag) {
            return Chip(label: Text(tag.name));
          }).toList(),
        );
      },
    );
  }
}

class _DatesInformationRow extends StatelessWidget {
  final Vocabulary vocabulary;
  const _DatesInformationRow({required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              children: [
                TextSpan(
                  text: "${context.s.common_vocabulary_created_label}\n",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: DateFormat("dd.MM.yyyy").format(vocabulary.created),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              children: [
                TextSpan(
                  text: "${context.s.common_vocabulary_reappears_label}\n",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: vocabulary.reappearsIn(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  final Vocabulary vocabulary;
  const _EditButton({required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    void edit() {
      context.pop();
      context.pushNamed(
        DetailsScreen.routeName,
        arguments: DetailsScreenArguments(vocabulary: vocabulary),
      );
    }

    return ElevatedButton(
      onPressed: edit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(Dimensions.semiSmallSpacing),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
      ),
      child: const Icon(Icons.edit),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    void close() {
      context.pop();
    }

    return Expanded(
      child: ElevatedButton(
        onPressed: close,
        child: Text(context.s.common_close),
      ),
    );
  }
}
