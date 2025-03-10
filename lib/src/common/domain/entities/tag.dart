class Tag {
  final String? id;
  final String? userId;
  final String name;
  final DateTime? created;
  final DateTime? updated;

  const Tag({
    this.id,
    this.userId,
    this.name = "",
    this.created,
    this.updated,
  });

  Tag copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? created,
    DateTime? updated,
  }) {
    return Tag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return "Tag(id: $id, userId: $userId, name: $name, created: $created, updated: $updated)";
  }
}
