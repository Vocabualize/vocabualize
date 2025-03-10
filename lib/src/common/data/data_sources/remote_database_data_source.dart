import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:log/log.dart';
import 'package:pocketbase/pocketbase.dart' as pb;
import 'package:vocabualize/constants/tracking_constants.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_connection_client.dart';
import 'package:vocabualize/src/common/data/extensions/string_extensions.dart';
import 'package:vocabualize/src/common/data/extensions/uint8list_extensions.dart';
import 'package:vocabualize/src/common/data/mappers/alert_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/auth_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/language_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/practice_iteration_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/report_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/tag_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/vocabulary_mappers.dart';
import 'package:vocabualize/src/common/data/models/rdb_alert.dart';
import 'package:vocabualize/src/common/data/models/rdb_bug_report.dart';
import 'package:vocabualize/src/common/data/models/rdb_language.dart';
import 'package:vocabualize/src/common/data/models/rdb_event_type.dart';
import 'package:vocabualize/src/common/data/models/rdb_practice_iteration.dart';
import 'package:vocabualize/src/common/data/models/rdb_tag.dart';
import 'package:vocabualize/src/common/data/models/rdb_translation_report.dart';
import 'package:vocabualize/src/common/data/models/rdb_vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';

final remoteDatabaseDataSourceProvider = Provider((ref) {
  return RemoteDatabaseDataSource(
    connectionClient: ref.watch(remoteConnectionClientProvider),
  );
});

class RemoteDatabaseDataSource {
  final RemoteConnectionClient _connectionClient;

  const RemoteDatabaseDataSource({
    required RemoteConnectionClient connectionClient,
  }) : _connectionClient = connectionClient;

  final String _trackingMessagePrefix = "TRACKING: ";
  final String _trackingPrefix = "tracking_";
  final String _trackingGeneral = "general";
  final String _trackingGather = "gather";
  final String _trackingPractice = "practice";

  final String _alertsCollectionName = "_alerts";

  final String _usersCollectionName = "users";
  final String _vocabulariesCollectionName = "vocabularies";
  final String _languagesCollectionName = "languages";
  final String _tagsCollectionName = "tags";
  final String _translationReportCollectionName = "translation_reports";
  final String _bugReportCollectionName = "bug_reports";

  final String _idField = "id";
  final String _userFieldName = "user";
  final String _customImageFieldName = "customImage";

  Future<List<RdbAlert>> getAlerts() async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final records = await pocketbase.collection(_alertsCollectionName).getList();
    return records.items.map((record) => record.toRdbAlert()).toList();
  }

  Future<AppUser?> getUser() async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    try {
      final user = await pocketbase
          .collection(_usersCollectionName)
          .getOne(pocketbase.authStore.toAppUser()?.id ?? "");
      return user.toAppUser();
    } on pb.ClientException catch (e) {
      Log.error("Could not load user.", exception: e);
      return null;
    }
  }

  Future<void> updateUser({
    String? sourceLanguageId,
    String? targetLanguageId,
    bool? keepData,
  }) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final model = pocketbase.authStore.model;
    final userRecord = model is pb.RecordModel? ? model : null;
    userRecord?.let((record) async {
      Map<String, String>? body = {};
      sourceLanguageId?.let((id) => body.addAll({"sourceLanguageId": id}));
      targetLanguageId?.let((id) => body.addAll({"targetLanguageId": id}));
      keepData?.let((keep) => body.addAll({"keepData": keep.toString()}));
      if (body.isEmpty) return;
      await pocketbase.collection(_usersCollectionName).update(record.id, body: body);
    });
  }

  String _getTrackingCollectionNameByEvent(String eventName) {
    return switch (eventName) {
      var s when s.startsWith(_trackingGather) => "$_trackingPrefix$_trackingGather",
      var s when s.startsWith(_trackingPractice) => "$_trackingPrefix$_trackingPractice",
      _ => "$_trackingPrefix$_trackingGeneral",
    };
  }

  Future<void> trackPracticeIteration(RdbPracticeIteration iteration) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    if (userId == null || !iteration.isValid) return;

    final encodedRecordId = userId.encodeTrackingId() ?? "";
    final collectionName = _getTrackingCollectionNameByEvent(TrackingConstants.practiceIterations);
    try {
      Log.debug("Tracking practice iteration: ${iteration.practicedCount}/${iteration.dueCount}");
      final record = await pocketbase.collection(collectionName).getOne(encodedRecordId);
      final iterations =
          record.getDataValue<List?>(TrackingConstants.practiceIterations)?.toJsonList() ?? [];
      iterations.add(iteration.toJson());
      await pocketbase.collection(collectionName).update(
        encodedRecordId,
        body: {
          TrackingConstants.practiceIterations: jsonEncode(iterations),
        },
      );
    } on pb.ClientException catch (e) {
      Log.warning("Update failed, creating new record: $e");
      try {
        final iterations = [iteration.toJson()];
        await pocketbase.collection(collectionName).create(body: {
          _idField: encodedRecordId,
          _userFieldName: userId,
          TrackingConstants.practiceIterations: jsonEncode(iterations),
        });
      } catch (e) {
        const message = "Could not create tracking record.";
        Log.error(message, exception: e);
        sendTrackingBugReport(
          message,
          eventName: TrackingConstants.practiceIterations,
          userId: userId,
          data: e.toString(),
        );
      }
    }
  }

  Future<void> trackEvent(String eventName) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    if (userId == null) return;
    final encodedRecordId = userId.encodeTrackingId() ?? "";
    final collectionName = _getTrackingCollectionNameByEvent(eventName);
    try {
      Log.hint("Tracking event: $eventName");
      await pocketbase.collection(collectionName).update(
        encodedRecordId,
        body: {"$eventName+": 1},
      );
    } on pb.ClientException catch (e) {
      Log.warning("Could not update tracking record. Creating new one. >> $e");
      try {
        await pocketbase.collection(collectionName).create(
          body: {
            _idField: encodedRecordId,
            _userFieldName: userId,
            "$eventName+": 1,
          },
        );
      } catch (e) {
        const message = "Could not create tracking record.";
        Log.error(message, exception: e);
        sendTrackingBugReport(
          message,
          eventName: eventName,
          userId: userId,
          data: e.toString(),
        );
      }
    }
  }

  Future<void> sendTrackingBugReport(
    String message, {
    String? eventName,
    String? userId,
    String? data,
  }) async {
    final bugDataList = [
      eventName?.let((x) => "eventName = $x"),
      userId?.let((x) => "userId = $x"),
      data?.let((x) => "data = $x"),
    ];
    final rdbBugReport = RdbBugReport(
      description: "$_trackingMessagePrefix $message",
      data: bugDataList.join(", "),
    );
    await sendBugReport(rdbBugReport);
  }

  Future<void> sendBugReport(RdbBugReport bugReport) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    try {
      await pocketbase
          .collection(_bugReportCollectionName)
          .create(body: bugReport.toRecordModel().toJson());
    } on ClientException catch (e) {
      Log.error("Could not send bug report because of bad connection.", exception: e);
    } on pb.ClientException catch (e) {
      Log.error("Could not send bug report.", exception: e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendTranslationReport(RdbTranslationReport translationReport) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    await pocketbase
        .collection(_translationReportCollectionName)
        .create(body: translationReport.toRecordModel().toJson());
  }

  Future<List<RdbLanguage>> getAvailabeLanguages() async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final records = await pocketbase.collection(_languagesCollectionName).getList();
    return records.items.map((record) => record.toRdbLanguage()).toList();
  }

  Future<RdbLanguage> getLanguageById(String id) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final record = await pocketbase.collection(_languagesCollectionName).getOne(id);
    return record.toRdbLanguage();
  }

  Future<List<RdbTag>> getTags() async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    final String? userFilter = userId?.let((id) => "$_userFieldName=\"$id\"");
    final tagsRecords =
        await pocketbase.collection(_tagsCollectionName).getFullList(filter: userFilter);
    return tagsRecords.map((record) => record.toRdbTag()).toList();
  }

  Future<RdbTag> getTagById(String id) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final record = await pocketbase.collection(_tagsCollectionName).getOne(id);
    return record.toRdbTag();
  }

  Future<String> createTag(RdbTag tag) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    final tagWithUser = tag.copyWith(user: userId);
    final data = tagWithUser.toRecordModel().toJson();
    final record = await pocketbase.collection(_tagsCollectionName).create(body: data);
    return record.id;
  }

  Future<String> updateTag(RdbTag tag) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    final tagWithUser = tag.copyWith(user: userId);
    final data = tagWithUser.toRecordModel().toJson();
    final recordModel = await pocketbase.collection(_tagsCollectionName).update(tag.id, body: data);
    return recordModel.id;
  }

  Future<void> deleteTag(RdbTag tag) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    await pocketbase.collection(_tagsCollectionName).delete(tag.id);
  }

  Future<List<RdbVocabulary>> getVocabularies({
    String? searchTerm,
    Tag? tag,
  }) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final String? searchFilter = searchTerm?.let((term) {
      return "source LIKE \"%$term%\" OR target LIKE \"%$term%\"";
    });
    final String? tagFilter = tag?.let((t) => "tags LIKE \"%${t.id}%\"");
    final String? userId = pocketbase.authStore.toAppUser()?.id;
    final String? userFilter = userId?.let((id) => "$_userFieldName=\"$id\"");
    final String filter = [
      userFilter,
      tagFilter,
      searchFilter,
    ].nonNulls.map((f) => "($f)").join(" AND ");

    try {
      final vocabularies = pocketbase
          .collection(_vocabulariesCollectionName)
          .getFullList(filter: filter)
          .then((value) async {
        return value.map((pb.RecordModel record) => record.toRdbVocabulary()).toList();
      });
      return vocabularies;
    } on SocketException catch (e) {
      Log.error("Could not load vocabularies because of bad connection.", exception: e);
      return [];
    } on ClientException catch (e) {
      Log.error("Could not load vocabularies because of bad connection.", exception: e);
      return [];
    } on pb.ClientException catch (e) {
      Log.error("Could not load vocabularies.", exception: e);
      // TODO: Implement AppResult to not use normal empty list
      return [];
    } catch (e) {
      Log.error("Unknow error while loading vocabularies.", exception: e);
      return [];
    }
  }

  void subscribeToVocabularyChanges(
    Function(RdbEventType type, RdbVocabulary rdbVocabulary) onEvent,
  ) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();

    // ? Unsubscribe from previous subscriptions
    // * (could lead to bugs, if different subscriptions with other topics are used)
    try {
      pocketbase.collection(_vocabulariesCollectionName).unsubscribe("*");
    } catch (e) {
      Log.error(
        "Failed to unsubscribe from previous vocabulary subscriptions.",
        exception: e,
      );
    }

    final userId = pocketbase.authStore.toAppUser()?.id;

    pocketbase.collection(_vocabulariesCollectionName).subscribe(
      "*",
      (pb.RecordSubscriptionEvent event) {
        // * This if statement replaces filter, since it didn't work here
        if (event.record?.getStringValue(_userFieldName) != userId) return;
        final eventType = switch (event.action) {
          "create" => RdbEventType.create,
          "update" => RdbEventType.update,
          "delete" => RdbEventType.delete,
          _ => null,
        };
        if (eventType == null) return;
        final vocabulary = event.record?.toRdbVocabulary();
        vocabulary?.let((v) {
          onEvent(eventType, v);
        });
      },
    );
  }

  Stream<List<RdbVocabulary>> getVocabularyStream({
    String? searchTerm,
    Tag? tag,
  }) async* {
    final controller = StreamController<List<RdbVocabulary>>();

    yield await getVocabularies(searchTerm: searchTerm, tag: tag);

    final pb.PocketBase pocketbase = await _connectionClient.getConnection();

    pocketbase.collection(_vocabulariesCollectionName).subscribe(
      "*",
      (event) async {
        final vocabularies = await getVocabularies(
          searchTerm: searchTerm,
          tag: tag,
        );
        controller.add(vocabularies);
      },
    );

    yield* controller.stream;
  }

  Future<void> addVocabulary(
    RdbVocabulary vocabulary, {
    Uint8List? draftImageToUpload,
  }) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    final vocabularyWithUser = vocabulary.copyWith(user: userId);
    final body = vocabularyWithUser.toRecordModel().toJson();

    // * Workaround. Creating records with images didn't work properly.

    final record = await pocketbase.collection(_vocabulariesCollectionName).create(body: body);

    draftImageToUpload?.let((image) async {
      await pocketbase.collection(_vocabulariesCollectionName).update(
        record.id,
        files: [
          MultipartFile.fromBytes(
            _customImageFieldName,
            await image.compress(),
            filename: "image.jpg",
          ),
        ],
      );
    });
  }

  Future<void> updateVocabulary(
    RdbVocabulary vocabulary, {
    Uint8List? draftImageToUpload,
  }) async {
    final id = vocabulary.id;
    if (id == null) return;

    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    final vocabularyWithUser = vocabulary.copyWith(user: userId);
    final body = vocabularyWithUser.toRecordModel().toJson();

    if (draftImageToUpload == null) {
      try {
        await pocketbase.collection(_vocabulariesCollectionName).update(id, body: body);
      } on pb.ClientException catch (e) {
        Log.error("Could not update vocabulary.", exception: e);
      }
    } else {
      try {
        await pocketbase.collection(_vocabulariesCollectionName).update(
          id,
          body: body,
          files: [
            MultipartFile.fromBytes(
              _customImageFieldName,
              await draftImageToUpload.compress(),
              filename: "image.jpg",
            ),
          ],
        );
      } on pb.ClientException catch (e) {
        Log.error("Could not update vocabulary.", exception: e);
      }
    }
  }

  Future<void> deleteVocabulary(RdbVocabulary vocabulary) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    final vocabularyWithUser = vocabulary.copyWith(user: userId);
    vocabularyWithUser.id?.let((id) async {
      try {
        await pocketbase.collection(_vocabulariesCollectionName).delete(id);
      } on pb.ClientException catch (e) {
        Log.error("Could not delete vocabulary.", exception: e);
      }
    });
  }

  Future<void> setKeepData(bool keepData) async {
    final pb.PocketBase pocketbase = await _connectionClient.getConnection();
    final userId = pocketbase.authStore.toAppUser()?.id;
    if (userId == null) return;
    final body = {"keepData": keepData};
    await pocketbase.collection(_usersCollectionName).update(userId, body: body);
  }
}
