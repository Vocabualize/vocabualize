import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:log/log.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:vocabualize/src/common/data/data_sources/authentication_data_source.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_connection_client.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_database_data_source.dart';
import 'package:vocabualize/src/common/data/mappers/auth_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/auth_provider.mappers.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/repositories/authentication_repository.dart';

final authenticationRepositoryProvider = Provider((ref) {
  return AuthenticationRepositoryImpl(
    authenticationDataSource: ref.watch(authenticationDataSourceProvider),
    connectionClient: ref.watch(remoteConnectionClientProvider),
    remoteDatabaseDataSource: ref.watch(remoteDatabaseDataSourceProvider),
  );
});

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final _usersCollectionName = "users";

  final AuthenticationDataSource _authenticationDataSource;
  final RemoteConnectionClient _connectionClient;
  final RemoteDatabaseDataSource _remoteDatabaseDataSource;

  final _userStreamController = StreamController<AppUser?>.broadcast();
  Stream<AppUser?> get stream {
    return _userStreamController.stream.asBroadcastStream();
  }

  AuthenticationRepositoryImpl({
    required AuthenticationDataSource authenticationDataSource,
    required RemoteConnectionClient connectionClient,
    required RemoteDatabaseDataSource remoteDatabaseDataSource,
  })  : _authenticationDataSource = authenticationDataSource,
        _connectionClient = connectionClient,
        _remoteDatabaseDataSource = remoteDatabaseDataSource {
    _initUserStream();
  }

  Future<void> _initUserStream() async {
    final PocketBase pocketbase = await _connectionClient.getConnection();
    _userStreamController.sink.add(pocketbase.authStore.toAppUser());
    final currentUser = await _remoteDatabaseDataSource.getUser();
    _userStreamController.sink.add(currentUser);
    _listenToUserChanges();
    Log.hint("User stream initialized");
  }

  void _listenToUserChanges() async {
    final PocketBase pocketbase = await _connectionClient.getConnection();
    Future<Future<void> Function()> userRecordSubscription(String userId) async {
      return await pocketbase.collection(_usersCollectionName).subscribe(userId, (action) {
        if (action.action == "update" || action.action == "delete") {
          _userStreamController.sink.add(action.record?.toAppUser());
        }
      });
    }

    // * Listen to current user record changes
    pocketbase.authStore.toAppUser()?.id?.let((userId) {
      userRecordSubscription(userId);
    });

    // * Listen to auth changes + user record changes
    final authSubscription = pocketbase.authStore.onChange.map((event) {
      final record = event.model;
      if (record == null || record is! RecordModel) return null;
      return record.toAppUser();
    }).listen((user) async {
      _userStreamController.sink.add(user);

      final userId = user?.id;
      if (userId != null) {
        userRecordSubscription(userId);
      }
    });

    _userStreamController.onCancel = () async {
      try {
        await authSubscription.cancel();
      } catch (error) {
        Log.warning("Unsubscribe error (safe to ignore): $error");
      }
    };
  }

  @override
  Stream<AppUser?> getCurrentUser() {
    return _userStreamController.stream;
  }

  @override
  Future<AuthProvider?> signInWithGithub(void Function(Uri) urlCallback) {
    return _authenticationDataSource.signInWithGithub(urlCallback).then((name) {
      return name?.toAuthProvider();
    });
  }

  @override
  Future<AuthProvider?> signInWithGoogle(void Function(Uri) urlCallback) {
    return _authenticationDataSource.signInWithGoogle(urlCallback).then((name) {
      return name?.toAuthProvider();
    });
  }

  @override
  Future<bool> createUserWithEmailAndPassword(String email, String password) {
    return _authenticationDataSource.createUserWithEmailAndPassword(
      // * Convert all emails to lowercase
      email.toLowerCase(),
      password,
    );
  }

  @override
  Future<bool> signInWithEmailAndPasswort(String email, String password) {
    return _authenticationDataSource.signInWithEmailAndPassword(
      // * All emails are saved as lowercase, so here we compare as lowercase
      email.toLowerCase(),
      password,
    );
  }

  @override
  Future<String?> signInAnonymously() async {
    return await _authenticationDataSource.signInAnonymously();
  }

  @override
  Future<bool> createGithubUserFromAnonymous(void Function(Uri) urlCallback) async {
    return await _authenticationDataSource.createGithubUserFromAnonymous(urlCallback);
  }

  @override
  Future<bool> createGoogleUserFromAnonymous(void Function(Uri) urlCallback) async {
    return await _authenticationDataSource.createGoogleUserFromAnonymous(urlCallback);
  }

  @override
  Future<bool> signOut() {
    return _authenticationDataSource.signOut();
  }

  @override
  Future<void> sendVerificationEmail() {
    return _authenticationDataSource.sendVerificationEmail();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authenticationDataSource.sendPasswordResetEmail(
      // * Since all emails are saved as lowercase, we send the email as lowercase
      email.toLowerCase(),
    );
  }
}
