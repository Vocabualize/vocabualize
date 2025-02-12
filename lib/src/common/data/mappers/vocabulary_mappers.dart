import 'package:pocketbase/pocketbase.dart';
import 'package:vocabualize/constants/due_algorithm_constants.dart';
import 'package:vocabualize/src/common/data/extensions/string_extensions.dart';
import 'package:vocabualize/src/common/data/mappers/vocabulary_image_mappers.dart';
import 'package:vocabualize/src/common/data/models/rdb_vocabulary.dart';
import 'package:vocabualize/src/common/data/models/rdb_vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/entities/level.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';

extension RecordModelMappers on RecordModel {
  RdbVocabulary toRdbVocabulary() {
    final stockImageJson = getDataValue<Map<String, dynamic>?>("stockImage", null);
    final stockImage = stockImageJson?.toRdbStockImage();
    final customImageName = getDataValue<String?>("customImage", null);
    final customImage = customImageName
        ?.takeUnless((name) => name.isEmpty)
        ?.toFileUrl(id, collectionName)
        ?.toRdbCustomImage();
    return RdbVocabulary(
      id: id,
      user: getStringValue("user", ""),
      source: getStringValue("source", ""),
      target: getStringValue("target", ""),
      sourceLanguageId: getStringValue("sourceLanguage", ""),
      targetLanguageId: getStringValue("targetLanguage", ""),
      tagIds: getListValue("tags", []),
      customImage: customImage,
      stockImage: stockImage,
      levelValue: getDoubleValue("levelValue", 0.0),
      isNovice: getBoolValue("isNovice", true),
      interval: getIntValue("interval", DueAlgorithmConstants.initialInterval),
      ease: getDoubleValue("ease", DueAlgorithmConstants.initialEase),
      nextDate: getStringValue("nextDate", DateTime.now().toUtc().toIso8601String()),
      created: created,
      updated: updated,
    );
  }
}

// !! TODO: Zeitzone fixen??? Oder liegt es doch an etwas anderem? => vergleich utc mit local

extension VocabularyModelMappers on RdbVocabulary {
  Vocabulary toVocabulary() {
    final rdbImage = customImage ?? stockImage;
    return Vocabulary(
      id: id,
      source: source,
      target: target,
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      tagIds: tagIds,
      image: rdbImage?.toVocabularyImage() ?? const FallbackImage(),
      level: Level(value: levelValue),
      isNovice: isNovice,
      interval: interval,
      ease: ease,
      nextDate: nextDate.toDateTimeOrNull(convertToLocal: true),
      created: created.toDateTimeOrNull(convertToLocal: true),
      updated: updated.toDateTimeOrNull(convertToLocal: true),
    );
  }

  RecordModel toRecordModel() {
    return RecordModel(
      id: id ?? "",
      data: {
        "user": user,
        "source": source,
        "target": target,
        "sourceLanguage": sourceLanguageId,
        "targetLanguage": targetLanguageId,
        "tags": tagIds,
        "customImage": customImage?.url.toFileName(),
        "stockImage": stockImage?.toRecordModel().toJson(),
        "levelValue": levelValue,
        "isNovice": isNovice,
        "interval": interval,
        "ease": ease,
        "nextDate": nextDate,
        "created": created,
        "updated": updated,
      },
    );
  }
}

extension VocabularyMappers on Vocabulary {
  RdbVocabulary toRdbVocabulary() {
    final rdbImage = image.toRdbImage();
    final customImage = rdbImage is RdbCustomImage ? rdbImage : null;
    final stockImage = rdbImage is RdbStockImage ? rdbImage : null;
    return RdbVocabulary(
      id: id,
      // * user id is added in data source
      user: "",
      source: source,
      target: target,
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      tagIds: tagIds,
      customImage: customImage,
      stockImage: stockImage,
      levelValue: level.value,
      isNovice: isNovice,
      interval: interval,
      ease: ease,
      nextDate: nextDate.toUtc().toIso8601String(),
      created: created.toUtc().toIso8601String(),
      updated: updated.toUtc().toIso8601String(),
    );
  }
}
