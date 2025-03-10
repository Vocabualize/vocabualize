import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/loading_screen.dart';
import 'package:vocabualize/src/common/presentation/widgets/deletion_confirmation_dialog.dart';
import 'package:vocabualize/src/features/details/presentation/controllers/details_controller.dart';
import 'package:vocabualize/src/features/details/presentation/states/details_state.dart';
import 'package:vocabualize/src/features/details/presentation/widgets/image_chooser.dart';
import 'package:vocabualize/src/features/details/presentation/widgets/source_to_target.dart';
import 'package:vocabualize/src/features/details/presentation/widgets/tag_wrap.dart';
import 'package:vocabualize/src/features/home/presentation/screens/home_screen.dart';

class DetailsScreenArguments {
  final Vocabulary vocabulary;
  DetailsScreenArguments({required this.vocabulary});
}

class DetailsScreen extends ConsumerWidget {
  static const String routeName = "${HomeScreen.routeName}/AddDetails";

  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DetailsScreenArguments? arguments =
        ModalRoute.of(context)?.settings.arguments as DetailsScreenArguments?;

    final vocabulary = arguments?.vocabulary;
    final provider = detailsControllerProvider(vocabulary);
    final notifier = provider.notifier;
    final asyncState = ref.watch(provider);

    return asyncState.when(
      loading: () => LoadingScreen(onCancel: context.pop),
      error: (_, __) => LoadingScreen(onCancel: context.pop),
      data: (DetailsState state) {
        if (state.vocabulary.source.isEmpty) {
          return LoadingScreen(onCancel: context.pop);
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(child: SourceToTarget(state: state, notifier: notifier)),
                const SizedBox(width: Dimensions.extraLargeSpacing),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.extraLargeSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!state.areImagesDisabled) ...[
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const SizedBox(height: Dimensions.smallSpacing),
                        ImageChooser(notifier: notifier, state: state),
                        if (state.areCollectionsEnabled) ...[
                          const SizedBox(height: Dimensions.mediumSpacing),
                          TagWrap(state: state, notifier: notifier),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  SourceToTarget(
                    state: state,
                    notifier: notifier,
                    isVertical: true,
                  ),
                  const Spacer(),
                  if (state.areCollectionsEnabled) ...[
                    TagWrap(state: state, notifier: notifier),
                  ],
                ],
                const SizedBox(height: Dimensions.mediumSpacing),
                Row(
                  children: [
                    if (state.vocabulary.id != null) ...[
                      _DeleteButton(vocabulary),
                      const SizedBox(width: Dimensions.semiSmallSpacing),
                    ],
                    Expanded(
                      child: _SaveButton(notifier: notifier, state: state),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.largeSpacing),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeleteButton extends ConsumerWidget {
  final Vocabulary? vocabulary;
  const _DeleteButton(this.vocabulary);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = detailsControllerProvider(vocabulary);
    final notifier = provider.notifier;

    final stateVocabulary = ref.watch(provider.select((state) {
      return state.valueOrNull?.vocabulary;
    }));

    void delete() {
      context.showDialog(DeletionConfirmationDialog(
        vocabulary: stateVocabulary,
        onDelete: () {
          ref.read(notifier).deleteVocabulary(context);
        },
      ));
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(Dimensions.semiSmallSpacing),
        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.2),
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
      onPressed: delete,
      child: const Icon(Icons.delete_rounded),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  final Refreshable<DetailsController> notifier;
  final DetailsState state;
  const _SaveButton({
    required this.notifier,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref.read(notifier).save(context);
      },
      child: Text(
        state.vocabulary.image is FallbackImage
            ? context.s.record_addDetails_saveWithoutButton
            : context.s.record_addDetails_saveButton,
      ),
    );
  }
}
