import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/constants/tracking_constants.dart';

import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/tracking/track_event_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/loading_screen.dart';
import 'package:vocabualize/src/features/record/presentation/controllers/record_controller.dart';
import 'package:vocabualize/src/features/record/presentation/states/record_state.dart';

class RecordScreen extends ConsumerWidget {
  static const String routeName = "/Record";
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = recordControllerProvider;
    final notifier = provider.notifier;
    final asyncState = ref.watch(provider);

    return asyncState.when(
      loading: () => LoadingScreen(onCancel: context.pop),
      error: (_, __) => LoadingScreen(onCancel: context.pop),
      data: (RecordState state) {
        final areSuggestionsLoading = state.suggestions == null;
        final foundSuggestions = state.suggestions?.isNotEmpty == true;
        return PopScope(
          canPop: state.imageBytes == null,
          onPopInvoked: (_) {
            ref.read(notifier).retakePhoto();
          },
          child: Scaffold(
            appBar: AppBar(title: null),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.largeSpacing,
                    ),
                    children: [
                      const SizedBox(height: Dimensions.mediumSpacing),
                      AspectRatio(
                        aspectRatio: 1 / 1,
                        child: _CameraBox(state: state, notifier: notifier),
                      ),
                      if (state.imageBytes != null) ...[
                        const SizedBox(height: Dimensions.largeSpacing),
                        _ManualSourceField(state: state, notifier: notifier),
                        const SizedBox(height: Dimensions.semiLargeSpacing),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(context.s.record_suggestions_label),
                        ),
                        if (areSuggestionsLoading) ...[
                          const SizedBox(height: Dimensions.semiSmallSpacing),
                          LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
                          ),
                        ] else ...[
                          if (foundSuggestions) ...[
                            const SizedBox(height: Dimensions.semiSmallSpacing),
                            _SuggestionsList(state: state, notifier: notifier),
                            const SizedBox(height: Dimensions.largeSpacing)
                          ] else ...[
                            const SizedBox(height: Dimensions.semiSmallSpacing),
                            Text(
                              context.s.record_suggestions_empty,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ],
                    ],
                  ),
                ),
                if (state.imageBytes == null) ...[
                  _TakePhotoButton(notifier: notifier),
                  const SizedBox(height: Dimensions.largeSpacing)
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CameraBox extends ConsumerWidget {
  final RecordState state;
  final Refreshable<RecordController> notifier;
  const _CameraBox({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        Dimensions.largeBorderRadius,
      ),
      child: state.imageBytes == null
          ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: state.cameraController.value.previewSize?.height,
                height: state.cameraController.value.previewSize?.width,
                child: CameraPreview(state.cameraController),
              ),
            )
          : state.imageBytes?.let((bytes) {
              return Image.memory(
                bytes,
                fit: BoxFit.cover,
              );
            }),
    );
  }
}

class _TakePhotoButton extends ConsumerWidget {
  final Refreshable<RecordController> notifier;
  const _TakePhotoButton({
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.large(
      heroTag: null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onPressed: () {
        ref.read(notifier).takePhotoAndScan();
      },
      child: const Icon(Icons.camera_alt_rounded),
    );
  }
}

class _ManualSourceField extends ConsumerWidget {
  final RecordState state;
  final Refreshable<RecordController> notifier;
  const _ManualSourceField({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Add the source language's flag as a leading?
    return TextField(
      decoration: InputDecoration(
        hintText: context.s.record_type,
      ),
      onSubmitted: (value) {
        ref.read(notifier).validateAndGoToDetails(context, source: value);
        ref.read(trackEventUseCaseProvider)(TrackingConstants.gatherScanManual);
      },
    );
  }
}

class _SuggestionsList extends ConsumerWidget {
  final RecordState state;
  final Refreshable<RecordController> notifier;
  const _SuggestionsList({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      restorationId: "SuggestionsList",
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.suggestions?.length ?? 0,
      itemBuilder: (context, index) {
        final suggestion = state.suggestions?.elementAt(index) ?? "";
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.smallSpacing),
          child: ListTile(
            title: Text(suggestion),
            tileColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
            ),
            onTap: () {
              ref.read(notifier).validateAndGoToDetails(context, source: suggestion);
              ref.read(trackEventUseCaseProvider)(TrackingConstants.gatherScan);
            },
          ),
        );
      },
    );
  }
}
