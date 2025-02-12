import 'package:pocketbase/pocketbase.dart';
import 'package:vocabualize/src/common/data/extensions/string_extensions.dart';
import 'package:vocabualize/src/common/data/mappers/auth_provider.mappers.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';

extension AuthStoreMappers on AuthStore {
  AppUser? toAppUser() {
    final record = model is RecordModel? ? model as RecordModel? : null;
    return record?.toAppUser();
  }
}

extension AuthStoreEventMappers on AuthStoreEvent {
  AppUser? toAppUser() {
    final record = model is RecordModel? ? model as RecordModel? : null;
    return record?.toAppUser();
  }
}

extension AuthRecordModelMappers on RecordModel {
  AppUser? toAppUser() {
    final avatarFileName = getDataValue<String?>("avatar")?.takeUnless((url) {
      return url.isEmpty;
    });
    final lastActive = getDataValue<String?>("lastActive") ?? "";
    return AppUser(
      id: id,
      provider: getDataValue<String?>("provider")?.toAuthProvider(),
      avatarUrl: avatarFileName?.toFileUrl(id, collectionName),
      name: getStringValue("name", "Anonymous"),
      email: getDataValue<String?>("email"),
      username: getDataValue<String?>("username"),
      lastActive: DateTime.tryParse(lastActive),
      streak: getDataValue<int?>("streak"),
      sourceLanguageId: getDataValue<String?>("sourceLanguageId"),
      targetLanguageId: getDataValue<String?>("targetLanguageId"),
      keepData: getBoolValue("keepData", false),
      created: DateTime.tryParse(created),
      updated: DateTime.tryParse(updated),
      verified: getDataValue<bool?>("verified"),
    );
  }
}
