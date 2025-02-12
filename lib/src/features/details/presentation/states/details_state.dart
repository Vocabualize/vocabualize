import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';

class DetailsState {
  final Vocabulary vocabulary;
  final VocabularyImage? customOrDraftImage;
  final List<StockImage> stockImages;
  final bool areCollectionsEnabled;
  final bool areImagesDisabled;
  final int firstStockImageIndex;
  final int lastStockImageIndex;
  final int stockImagesPerPage;

  const DetailsState({
    required this.vocabulary,
    required this.customOrDraftImage,
    required this.stockImages,
    required this.areCollectionsEnabled,
    required this.areImagesDisabled,
    this.firstStockImageIndex = 0,
    this.lastStockImageIndex = 6,
  }) : stockImagesPerPage = 7;

  int get totalStockImages => stockImages.length;

  DetailsState copyWith({
    Vocabulary? vocabulary,
    VocabularyImage? customOrDraftImage,
    List<StockImage>? stockImages,
    bool? areCollectionsEnabled,
    bool? areImagesDisabled,
    int? firstStockImageIndex,
    int? lastStockImageIndex,
  }) {
    return DetailsState(
      vocabulary: vocabulary ?? this.vocabulary,
      customOrDraftImage: customOrDraftImage ?? this.customOrDraftImage,
      stockImages: stockImages ?? this.stockImages,
      areCollectionsEnabled: areCollectionsEnabled ?? this.areCollectionsEnabled,
      areImagesDisabled: areImagesDisabled ?? this.areImagesDisabled,
      firstStockImageIndex: firstStockImageIndex ?? this.firstStockImageIndex,
      lastStockImageIndex: lastStockImageIndex ?? this.lastStockImageIndex,
    );
  }
}
