import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/domain/entities/filter_options.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_vocabularies_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/collections/presentation/states/collection_state.dart';
import 'package:vocabualize/src/features/practice/presentation/screens/practice_screen.dart';

final collectionControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<CollectionController, CollectionState, Tag?>(() {
  return CollectionController();
});

class CollectionController extends AutoDisposeFamilyAsyncNotifier<CollectionState, Tag?> {
  @override
  Future<CollectionState> build(Tag? arg) async {
    final tag = arg ?? const Tag();
    return CollectionState(
      tag: tag,
      tagVocabularies: ref.watch(getVocabulariesUseCaseProvider)(
        filterOptions: FilterOptions(tag: tag),
      ),
      areImagesDisabled: await ref.watch(getAreImagesDisabledUseCaseProvider.future),
    );
  }

  void editTag() {
    // TODO: implement edit tag / collection
  }

  void startPractice(BuildContext context) {
    state.value?.let((value) {
      context.pushNamed(
        PracticeScreen.routeName,
        arguments: PracticeScreenArguments(tag: value.tag),
      );
    });
  }
}
