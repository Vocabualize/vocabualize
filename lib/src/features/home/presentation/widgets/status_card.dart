import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/config/themes/level_palette.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/level.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/home/domain/utils/card_generator.dart';
import 'package:vocabualize/src/features/home/presentation/controllers/home_controller.dart';
import 'package:vocabualize/src/common/presentation/widgets/status_card_indicator.dart';
import 'package:vocabualize/src/features/practice/presentation/screens/practice_screen.dart';

class StatusCard extends ConsumerWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.semiLargeSpacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardMessage(),
          SizedBox(height: Dimensions.semiLargeSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LevelStatistics(),
              StatusCardIndicator(
                parent: _PracticeButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardMessage extends ConsumerWidget {
  const _CardMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularies = ref.watch(homeControllerProvider.select((s) {
      return s.value?.vocabularies ?? [];
    }));
    final message = CardGenerator.generateMessage(context, vocabularies);
    return Text(
      message,
      style: Theme.of(context).textTheme.displayMedium,
      textAlign: TextAlign.left,
    );
  }
}

class _LevelStatistics extends ConsumerWidget {
  const _LevelStatistics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularies = ref.watch(homeControllerProvider.select((s) {
      return s.value?.vocabularies ?? [];
    }));
    final levelCounts = vocabularies.fold<Map<Type, int>>(
      {BeginnerLevel: 0, AdvancedLevel: 0, ExpertLevel: 0},
      (counts, voc) {
        counts.update(voc.level.runtimeType, (x) => x + 1, ifAbsent: () => 1);
        return counts;
      },
    );
    final beginnerCount = levelCounts[BeginnerLevel] ?? 0;
    final advancedCount = levelCounts[AdvancedLevel] ?? 0;
    final expertCount = levelCounts[ExpertLevel] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Icon(Icons.circle, color: LevelPalette.beginner),
            Text("$beginnerCount"),
          ],
        ),
        const SizedBox(width: Dimensions.semiSmallSpacing),
        Column(
          children: [
            const Icon(Icons.circle, color: LevelPalette.advanced),
            Text("$advancedCount"),
          ],
        ),
        const SizedBox(width: Dimensions.semiSmallSpacing),
        Column(
          children: [
            const Icon(Icons.circle, color: LevelPalette.expert),
            Text("$expertCount"),
          ],
        ),
      ],
    );
  }
}

class _PracticeButton extends StatelessWidget {
  const _PracticeButton();

  @override
  Widget build(BuildContext context) {
    void startPractice() {
      context.pushNamed(PracticeScreen.routeName);
    }

    return ElevatedButton(
      onPressed: () => startPractice(),
      child: Text(
        context.s.home_statusCard_practiceButton,
      ),
    );
  }
}
