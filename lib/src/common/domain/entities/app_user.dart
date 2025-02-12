import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';

class AppUser {
  final String? id;
  final AuthProvider? provider;
  final String? avatarUrl;
  final String? name;
  final String? email;
  final String? username;
  final DateTime? lastActive;
  final int? streak;
  final String? sourceLanguageId;
  final String? targetLanguageId;
  final bool? keepData;
  final DateTime? created;
  final DateTime? updated;
  final bool? verified;

  String get displayName {
    return name?.takeUnless((n) => n.isEmpty) ??
        username?.takeUnless((n) => n.isEmpty) ??
        "Anonymous";
  }

  String get info {
    return email?.takeUnless((e) => e.isEmpty) ?? "No email";
  }

  const AppUser({
    this.id,
    this.provider,
    this.avatarUrl,
    this.name,
    this.email,
    this.username,
    this.lastActive,
    this.streak,
    this.sourceLanguageId,
    this.targetLanguageId,
    this.keepData,
    this.created,
    this.updated,
    this.verified,
  });

  AppUser copyWith({
    String? id,
    AuthProvider? provider,
    String? avatarUrl,
    String? name,
    String? email,
    String? username,
    DateTime? lastActive,
    int? streak,
    String? sourceLanguageId,
    String? targetLanguageId,
    bool? keepData,
    DateTime? created,
    DateTime? updated,
    bool? verified,
  }) {
    return AppUser(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      lastActive: lastActive ?? this.lastActive,
      streak: streak ?? this.streak,
      sourceLanguageId: sourceLanguageId ?? this.sourceLanguageId,
      targetLanguageId: targetLanguageId ?? this.targetLanguageId,
      keepData: keepData ?? this.keepData,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      verified: verified ?? this.verified,
    );
  }

  @override
  String toString() {
    return "AppUser("
        "id: $id, "
        "provider: $provider, "
        "avatarUrl: $avatarUrl, "
        "name: $name, "
        "email: $email, "
        "username: $username, "
        "lastActive: $lastActive, "
        "streak: $streak, "
        "sourceLanguageId: $sourceLanguageId, "
        "targetLanguageId: $targetLanguageId, "
        "keepData: $keepData, "
        "created: $created, "
        "updated: $updated, "
        "verified: $verified"
        ")";
  }

  @override
  // ignore: hash_and_equals
  operator ==(Object other) {
    if (other is AppUser) {
      return id == other.id;
    }
    return false;
  }
}
