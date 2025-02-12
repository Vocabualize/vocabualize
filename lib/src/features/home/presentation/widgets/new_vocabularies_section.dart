import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/presentation/extensions/vocabulary_image_extensions.dart';
import 'package:vocabualize/src/features/home/presentation/controllers/home_controller.dart';

class NewVocabulariesSection extends ConsumerWidget {
  const NewVocabulariesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newVocabularies = ref.watch(homeControllerProvider.select((s) {
      return s.value?.newVocabularies ?? [];
    }));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: Dimensions.mediumSpacing),
          for (final vocabulary in newVocabularies) ...[
            const SizedBox(width: Dimensions.smallSpacing),
            _NewVocabularyCard(vocabulary: vocabulary),
          ],
          const SizedBox(width: Dimensions.semiLargeSpacing),
        ],
      ),
    );
  }
}

class _NewVocabularyCard extends ConsumerWidget {
  final Vocabulary vocabulary;

  const _NewVocabularyCard({
    required this.vocabulary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const cardSpacing = 128.0;

    final provider = homeControllerProvider;
    final notifier = provider.notifier;
    final areImagesDisabled = ref.watch(provider.select((s) {
      return s.value?.areImagesDisabled ?? false;
    }));

    return MaterialButton(
      elevation: 0,
      disabledElevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      padding: areImagesDisabled
          ? const EdgeInsets.all(Dimensions.mediumSpacing)
          : const EdgeInsets.all(Dimensions.smallSpacing),
      color: areImagesDisabled ? Theme.of(context).colorScheme.surface : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
        side: areImagesDisabled
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: Dimensions.mediumBorderWidth,
              )
            : BorderSide.none,
      ),
      onPressed: () {
        ref.read(notifier).showVocabularyInfo(context, vocabulary);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!areImagesDisabled) ...[
            _ImageBox(
              cardSpacing: cardSpacing,
              vocabulary: vocabulary,
            ),
            const SizedBox(height: Dimensions.smallSpacing),
          ],
          _LabelContainer(
            cardSpacing: cardSpacing,
            label: vocabulary.target,
          ),
          _LabelContainer(
            cardSpacing: cardSpacing,
            label: vocabulary.source,
            textColor: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final double cardSpacing;
  final Vocabulary vocabulary;
  const _ImageBox({
    required this.cardSpacing,
    required this.vocabulary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardSpacing,
      height: cardSpacing,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
        child: vocabulary.image.getImage(
          fit: BoxFit.cover,
          size: ImageSize.medium,
        ),
      ),
    );
  }
}

class _LabelContainer extends ConsumerWidget {
  final double cardSpacing;
  final String label;
  final Color? textColor;
  const _LabelContainer({
    required this.cardSpacing,
    required this.label,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areImagesDisabled = ref.read(homeControllerProvider.select((s) {
      return s.value?.areImagesDisabled ?? false;
    }));
    return Container(
      width: cardSpacing,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.extraSmallSpacing,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: areImagesDisabled ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
