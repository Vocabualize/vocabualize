import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/level.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/vocabulary_image_extensions.dart';

class DeletionConfirmationDialog extends ConsumerWidget {
  final Vocabulary? vocabulary;
  final VoidCallback onDelete;
  const DeletionConfirmationDialog({
    required this.vocabulary,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void cancel() {
      context.pop();
    }

    void delete() {
      onDelete();
      context.pop();
    }

    final safeVocabulary = vocabulary;

    return AlertDialog.adaptive(
      insetPadding: const EdgeInsets.all(Dimensions.dialogMediumInsetSpacing),
      contentPadding: const EdgeInsets.only(
        left: Dimensions.semiLargeSpacing,
        right: Dimensions.semiLargeSpacing,
        top: Dimensions.semiSmallSpacing,
        bottom: 0,
      ),
      title: Text(context.s.common_delete_dialog_title),
      content: safeVocabulary != null
          ? _VocabularyListTile(safeVocabulary)
          : Text(context.s.common_delete_dialog_empty_content),
      actionsPadding: const EdgeInsets.all(Dimensions.semiLargeSpacing),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(Dimensions.semiSmallSpacing),
          ),
          onPressed: cancel,
          child: Text(context.s.common_cancel),
        ),
        ElevatedButton(
          onPressed: delete,
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: Text(context.s.common_delete),
        ),
      ],
    );
  }
}

class _VocabularyListTile extends ConsumerWidget {
  final Vocabulary vocabulary;
  const _VocabularyListTile(this.vocabulary);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LevelIndicator(level: vocabulary.level),
          ...ref.watch(getAreImagesDisabledUseCaseProvider).maybeWhen(
            data: (areImagesDisabled) {
              if (areImagesDisabled) return [];
              return [
                const SizedBox(width: Dimensions.semiSmallSpacing),
                _ImageBox(image: vocabulary.image),
              ];
            },
            orElse: () {
              return const [];
            },
          ),
        ],
      ),
      title: Text(
        vocabulary.target,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        vocabulary.source,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
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
      margin: const EdgeInsets.symmetric(
        vertical: Dimensions.smallSpacing,
      ),
      width: Dimensions.extraSmallSpacing,
      decoration: BoxDecoration(
        color: level.color,
        borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final VocabularyImage image;
  const _ImageBox({required this.image});

  @override
  Widget build(BuildContext context) {
    const avatarSize = 48.0;
    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          Dimensions.semiSmallBorderRadius,
        ),
        child: image.getImage(
          fit: BoxFit.cover,
          size: ImageSize.tiny,
        ),
      ),
    );
  }
}
