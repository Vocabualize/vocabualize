import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/collections/presentation/controllers/collection_controller.dart';
import 'package:vocabualize/src/features/home/presentation/screens/home_screen.dart';
import 'package:vocabualize/src/common/presentation/widgets/status_card_indicator.dart';
import 'package:vocabualize/src/common/presentation/widgets/vocabulary_list_tile.dart';

class CollectionScreenArguments {
  final Tag tag;
  CollectionScreenArguments({required this.tag});
}

class CollectionScreen extends ConsumerWidget {
  static const String routeName = "${HomeScreen.routeName}/Collection";

  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CollectionScreenArguments? arguments =
        ModalRoute.of(context)?.settings.arguments as CollectionScreenArguments?;

    final provider = collectionControllerProvider(arguments?.tag);
    final notifier = provider.notifier;

    final tag = ref.watch(provider.select((s) {
      return s.value?.tag ?? const Tag();
    }));

    final tagVocabularies = ref.watch(provider.select((s) {
      return s.value?.tagVocabularies ?? [];
    }));

    return Scaffold(
      appBar: AppBar(
        title: _CollectionTitle(tag: tag),
        actions: [_EditButton(notifier: notifier)],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.largeSpacing),
        children: [
          const SizedBox(height: Dimensions.mediumSpacing),
          StatusCardIndicator(
            tag: tag,
            parent: _PracticeButton(notifier: notifier),
          ),
          const SizedBox(height: Dimensions.mediumSpacing),
          for (final vocabulary in tagVocabularies.reversed)
            VocabularyListTile(vocabulary: vocabulary),
          const SizedBox(height: Dimensions.scrollEndSpacing),
        ],
      ),
    );
  }
}

class _CollectionTitle extends ConsumerWidget {
  final Tag tag;
  const _CollectionTitle({required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      tag.name,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class _EditButton extends ConsumerWidget {
  final Refreshable<CollectionController> notifier;
  const _EditButton({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit_rounded),
      onPressed: ref.read(notifier).editTag,
    );
  }
}

class _PracticeButton extends ConsumerWidget {
  final Refreshable<CollectionController> notifier;
  const _PracticeButton({
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ref.read(notifier).startPractice(context);
        },
        child: Text(context.s.home_statusCard_practiceButton),
      ),
    );
  }
}
