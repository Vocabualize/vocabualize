import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/vocabulary_image_extensions.dart';
import 'package:vocabualize/src/features/details/presentation/controllers/details_controller.dart';
import 'package:vocabualize/src/features/details/presentation/states/details_state.dart';

class ImageChooser extends ConsumerWidget {
  final Refreshable<DetailsController> notifier;
  final DetailsState state;
  const ImageChooser({
    required this.notifier,
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: _SelectedImageBox(state, notifier),
        ),
        const SizedBox(height: Dimensions.mediumSpacing),
        _ProviderHintWithReloadButton(notifier),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: min(
            state.stockImages.length + 1,
            state.stockImagesPerPage + 1,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _CustomImageButton(notifier: notifier, state: state);
            }
            return _StockImageButton(
              notifier: notifier,
              state: state,
              stockImage: state.stockImages.elementAt(
                index + state.firstStockImageIndex - 1,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SelectedImageBox extends StatelessWidget {
  final DetailsState state;
  final Refreshable<DetailsController> notifier;
  const _SelectedImageBox(this.state, this.notifier);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          Dimensions.mediumBorderRadius,
        ),
        border: Border.all(
          width: Dimensions.mediumBorderWidth,
          color: Theme.of(context).colorScheme.primary,
        ),
        color: Theme.of(context).colorScheme.surface,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: state.vocabulary.image.getImageProvider(),
        ).takeUnless((_) => state.vocabulary.image is FallbackImage),
      ),
      child: switch (state.vocabulary.image.runtimeType) {
        const (DraftImage) || const (CustomImage) => _RetakeButton(notifier: notifier),
        const (FallbackImage) => const _NoImageMessage(),
        const (StockImage) => _PhotographerLink(state, notifier),
        _ => null,
      },
    );
  }
}

class _NoImageMessage extends StatelessWidget {
  const _NoImageMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.s.record_addDetails_noImage,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  final Widget child;
  const _GradientOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // * -2 is a fix, otherwise gradient is slightly overlapping its parent
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius - 2),
        backgroundBlendMode: BlendMode.darken,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter / 12,
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    );
  }
}

class _RetakeButton extends ConsumerWidget {
  final Refreshable<DetailsController> notifier;
  const _RetakeButton({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GradientOverlay(
      child: TextButton(
        onPressed: () {
          ref.read(notifier).getDraftImage(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.replay_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: Dimensions.smallIconSize,
            ),
            const SizedBox(width: Dimensions.smallSpacing),
            Text(
              "Retake image",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotographerLink extends ConsumerWidget {
  final DetailsState state;
  final Refreshable<DetailsController> notifier;
  const _PhotographerLink(
    this.state,
    this.notifier,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = (state.vocabulary.image as StockImage).photographer;
    return _GradientOverlay(
      child: TextButton(
        onPressed: () {
          ref.read(notifier).openPhotographerLink();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: Dimensions.smallSpacing),
            Flexible(
              child: Text(
                context.s.details_photo_by(author ?? context.s.common_unknown),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
            const SizedBox(width: Dimensions.smallSpacing),
            Icon(
              Icons.launch_rounded,
              size: Dimensions.smallIconSize,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: Dimensions.smallSpacing),
          ],
        ),
      ),
    );
  }
}

class _ProviderHintWithReloadButton extends ConsumerWidget {
  final Refreshable<DetailsController> notifier;
  const _ProviderHintWithReloadButton(this.notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.s.record_addDetails_providedBy,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        IconButton(
          onPressed: () {
            ref.read(notifier).browseNext();
          },
          icon: const Icon(Icons.find_replace_rounded),
        ),
      ],
    );
  }
}

class _CustomImageButton extends ConsumerWidget {
  final Refreshable<DetailsController> notifier;
  final DetailsState state;
  const _CustomImageButton({
    required this.notifier,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      elevation: 0,
      onPressed: () {
        final isNotNull = state.customOrDraftImage != null;
        final isNotSelected = state.customOrDraftImage != state.vocabulary.image;
        if (isNotNull && isNotSelected) {
          ref.read(notifier).selectOrUnselectImage(state.customOrDraftImage);
        } else {
          ref.read(notifier).getDraftImage(context);
        }
      },
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
      child: state.customOrDraftImage != null
          ? _CustomImageWithIcon(state)
          : Icon(
              Icons.camera_alt_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: Dimensions.largeIconSize,
            ),
    );
  }
}

class _CustomImageWithIcon extends StatelessWidget {
  final DetailsState state;
  const _CustomImageWithIcon(this.state);

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          Dimensions.mediumBorderRadius,
        ),
        border: Border.all(
          width: Dimensions.mediumBorderWidth,
          color: Theme.of(context).colorScheme.primary,
        ).takeIf((_) {
          final isNotNull = state.customOrDraftImage != null;
          final isSelected = state.customOrDraftImage == state.vocabulary.image;
          return isNotNull && isSelected;
        }),
        color: Theme.of(context).colorScheme.surface,
        image: state.customOrDraftImage?.let((image) {
          return DecorationImage(
            fit: BoxFit.cover,
            image: image.getImageProvider(),
          );
        }),
      ),
      child: Center(
        child: Icon(
          Icons.camera_alt_rounded,
          color: Theme.of(context).colorScheme.onSurface,
          size: Dimensions.largeIconSize,
        ),
      ),
    );
  }
}

class _StockImageButton extends ConsumerWidget {
  final Refreshable<DetailsController> notifier;
  final DetailsState state;
  final StockImage stockImage;
  const _StockImageButton({
    required this.notifier,
    required this.state,
    required this.stockImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = state.vocabulary.image is StockImage &&
        (state.vocabulary.image as StockImage).id == stockImage.id;
    return InkWell(
      onTap: () => ref.read(notifier).selectOrUnselectImage(stockImage),
      borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            Dimensions.mediumBorderRadius,
          ),
          border: Border.all(
            width: Dimensions.mediumBorderWidth,
            color: Theme.of(context).colorScheme.primary,
          ).takeIf((_) => isSelected),
          color: Theme.of(context).colorScheme.surface,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: stockImage.getImageProvider(size: ImageSize.small),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.done_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ).takeIf((_) => isSelected),
      ),
    );
  }
}
