class RdbTag {
  final String id;
  final String user;
  final String name;
  final String? created;
  final String? updated;

  const RdbTag({
    this.id = "",
    this.user = "",
    this.name = "",
    this.created,
    this.updated,
  });

  RdbTag copyWith({
    String? id,
    String? user,
    String? name,
    String? created,
    String? updated,
  }) {
    return RdbTag(
      id: id ?? this.id,
      user: user ?? this.user,
      name: name ?? this.name,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
