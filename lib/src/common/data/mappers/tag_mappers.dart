import 'package:pocketbase/pocketbase.dart';
import 'package:vocabualize/src/common/data/models/rdb_tag.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';

extension RecordModelTagMappers on RecordModel {
  RdbTag toRdbTag() {
    return RdbTag(
      id: id,
      user: getStringValue("user"),
      name: data['name'],
      created: data['created'],
      updated: data['updated'],
    );
  }
}

extension RdbTagMappers on RdbTag {
  Tag toTag() {
    return Tag(
      id: id,
      userId: user,
      name: name,
    );
  }

  RecordModel toRecordModel() {
    return RecordModel(
      id: id,
      data: {
        "user": user,
        "name": name,
      },
    );
  }
}

extension TagMappers on Tag {
  RdbTag toRdbTag() {
    return RdbTag(
      id: id ?? "",
      user: userId ?? "",
      name: name,
    );
  }
}
