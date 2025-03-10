import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:log/log.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_connection_client.dart';
import 'package:vocabualize/src/common/data/extensions/map_extensions.dart';
import 'package:vocabualize/src/common/data/mappers/auth_mappers.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/extensions/string_extensions.dart';

final authenticationDataSourceProvider = Provider((ref) {
  return AuthenticationDataSource(
    connectionClient: ref.watch(remoteConnectionClientProvider),
  );
});

class AuthenticationDataSource {
  final RemoteConnectionClient _connectionClient;
  final String _usersCollectionName = "users";
  final String _idFieldName = "id";
  final String _avatarFieldName = "avatar";
  final String _avatarMetaName = "avatarURL";
  final String _nameFieldName = "name";
  final String _usernameFieldName = "username";
  final String _emailFieldName = "email";
  final String _passwordFieldName = "password";
  final String _passwordConfirmFieldName = "passwordConfirm";
  final String _providerFieldName = "provider";
  final String _anonymousProviderName = "anonymous";
  final String _githubProviderName = "github";
  final String _googleProviderName = "google";

  const AuthenticationDataSource({
    required RemoteConnectionClient connectionClient,
  }) : _connectionClient = connectionClient;

  Future<String?> signInWithGithub(void Function(Uri) urlCallback) {
    return _signInWithOAuth2(_githubProviderName, urlCallback);
  }

  Future<String?> signInWithGoogle(void Function(Uri) urlCallback) {
    return _signInWithOAuth2(_googleProviderName, urlCallback);
  }

  /// Returns name of provider linked with account.
  Future<String?> _signInWithOAuth2(
    String providerName,
    void Function(Uri) urlCallback,
  ) async {
    try {
      final pocketbase = await _connectionClient.getConnection();

      if (pocketbase.authStore.model != null) {
        Log.hint("Already signed in. Signing out...");
        await signOut();
      }

      final authData = await pocketbase
          .collection(_usersCollectionName)
          .authWithOAuth2(providerName, urlCallback);

      final record = authData.record;

      if (record == null) {
        return null;
      }

      String? linkedProviderName = record.getDataValue<String?>(_providerFieldName);

      if (linkedProviderName.isNullOrEmpty()) {
        await pocketbase.collection(_usersCollectionName).update(record.id, body: {
          _providerFieldName: providerName,
        });
        linkedProviderName = providerName;
      }

      if (linkedProviderName != providerName) {
        Log.error("Tried signing in with $providerName, but linked with $linkedProviderName.");
        await signOut();
      }

      return linkedProviderName;
    } on Exception catch (e) {
      Log.error("Failed to sign in with OAuth2 ($providerName).", exception: e);
      return null;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      final pocketbase = await _connectionClient.getConnection();
      final RecordAuth authData =
          await pocketbase.collection(_usersCollectionName).authWithPassword(email, password);
      pocketbase.authStore.save(authData.token, authData.record);
      Log.hint("Signed in with email and password (AuthData: $authData)");
      return true;
    } catch (e) {
      Log.error("Failed to sign in with passwort.", exception: e);
      return false;
    }
  }

  // ! createUserWithEmailAndPassword is outdated.
  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final pocketbase = await _connectionClient.getConnection();
      final RecordModel authData = await pocketbase.collection(_usersCollectionName).create(body: {
        _emailFieldName: email,
        _passwordFieldName: password,
        _passwordConfirmFieldName: password,
      });
      Log.hint("Created user with email and password (AuthData: $authData)");
      return true;
    } catch (e) {
      Log.error("Failed to create user with email and password.", exception: e);
      return false;
    }
  }

  /// Returns localUserId of the anonymous user who signed in.
  Future<String?> signInAnonymously() async {
    try {
      final pocketbase = await _connectionClient.getConnection();
      final localUserId = const Uuid().v4().toString().replaceAll("-", "").substring(0, 15);
      final userName = "user-$localUserId";

      await pocketbase.collection(_usersCollectionName).create(body: {
        _idFieldName: localUserId,
        _usernameFieldName: userName,
        _passwordFieldName: localUserId,
        _passwordConfirmFieldName: localUserId,
        _providerFieldName: _anonymousProviderName,
      });

      await pocketbase.collection(_usersCollectionName).authWithPassword(userName, localUserId);

      Log.hint("Signed in anonymously ($userName)");
      return localUserId;
    } catch (e) {
      Log.error("Failed to sign in anonymously.", exception: e);
      return null;
    }
  }

  Future<bool> createGithubUserFromAnonymous(void Function(Uri) urlCallback) {
    return _createOauthUserFromAnonymous(_githubProviderName, urlCallback);
  }

  Future<bool> createGoogleUserFromAnonymous(void Function(Uri) urlCallback) {
    return _createOauthUserFromAnonymous(_googleProviderName, urlCallback);
  }

  Future<bool> _createOauthUserFromAnonymous(
    String providerName,
    void Function(Uri) urlCallback,
  ) async {
    final pocketbase = await _connectionClient.getConnection();
    final anonymousUser = pocketbase.authStore.toAppUser();
    final anonymousUserId = anonymousUser?.id;

    if (anonymousUserId == null || anonymousUser?.provider != AuthProvider.anonymous) {
      Log.error(
        "createOauthUserFromAnonymous(..): Anonymous user not found.",
        exception: "anonymousUser?.provider = ${anonymousUser?.provider}",
      );
      return false;
    }

    RecordAuth? oauthUser;
    try {
      pocketbase.realtime.unsubscribe();

      oauthUser = await pocketbase.collection(_usersCollectionName).authWithOAuth2(
        providerName,
        urlCallback,
        createData: {
          // * This is a dirty workaround, lol. CreateData will actually never be used by the
          // * Pocketbase SDK, because authStore != null. But we misuse it to pass a payload
          // * to the server-side OAuth2 event hook.
          "anonymousUserId": anonymousUserId,
        },
      );
    } catch (e) {
      Log.warning("createOauthUserFromAnonymous(..): OAuth2 failed. Perhaps, user already exists.");
      oauthUser = null;
    }

    await pocketbase.collection(_usersCollectionName).authRefresh();

    final oauthAppUser = oauthUser?.record?.toAppUser();
    if (oauthAppUser?.provider == null) {
      Log.error("createOauthUserFromAnonymous(..): OAuth2 user's provider is null.");
      return false;
    }
    if (oauthAppUser?.id != anonymousUserId) {
      Log.warning("createOauthUserFromAnonymous(..): Already linked to: ${oauthAppUser?.id}");
      return false;
    }

    try {
      final avatarUrl = Uri.tryParse(oauthUser?.meta.get(_avatarMetaName, "") ?? "");
      final avatarReponse = await avatarUrl?.let((uri) async => await http.get(uri));
      final avatarData = avatarReponse?.bodyBytes;

      await pocketbase.collection(_usersCollectionName).update(
        anonymousUserId,
        body: {
          _nameFieldName: oauthUser?.meta.get<String>(_nameFieldName, null),
          _providerFieldName: providerName,
        },
        files: [
          http.MultipartFile.fromBytes(
            _avatarFieldName,
            avatarData ?? [],
            filename: "avatar.jpg",
          ),
        ],
      );
    } catch (e) {
      Log.error(
        "createOauthUserFromAnonymous(..): Failed to update anonymous user.",
        exception: e,
      );
      return false;
    }

    return true;
  }

  Future sendVerificationEmail() async {
    // TODO: Implement sendVerificationEmail
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // TODO: Implement sendPasswordResetEmail
  }

  Future<bool> signOut() async {
    try {
      await _connectionClient.clearConnection();
      return true;
    } catch (e) {
      Log.error("Failed to sign out.", exception: e);
      return false;
    }
  }
}
