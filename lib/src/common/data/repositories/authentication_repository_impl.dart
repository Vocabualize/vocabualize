import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:log/log.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:vocabualize/src/common/data/data_sources/authentication_data_source.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_connection_client.dart';
import 'package:vocabualize/src/common/data/mappers/auth_mappers.dart';
import 'package:vocabualize/src/common/data/mappers/auth_provider.mappers.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/repositories/authentication_repository.dart';

final authenticationRepositoryProvider = Provider((ref) {
  return AuthenticationRepositoryImpl(
    connectionClient: ref.watch(remoteConnectionClientProvider),
    authenticationDataSource: ref.watch(authenticationDataSourceProvider),
  );
});

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final RemoteConnectionClient _connectionClient;
  final AuthenticationDataSource _authenticationDataSource;

  final _userStreamController = StreamController<AppUser?>.broadcast();
  Stream<AppUser?> get stream {
    return _userStreamController.stream.asBroadcastStream();
  }

  AuthenticationRepositoryImpl({
    required RemoteConnectionClient connectionClient,
    required AuthenticationDataSource authenticationDataSource,
  })  : _connectionClient = connectionClient,
        _authenticationDataSource = authenticationDataSource {
    _initUserStream();
  }

  Future<void> _initUserStream() async {
    final PocketBase pocketbase = await _connectionClient.getConnection();
    _userStreamController.sink.add(pocketbase.authStore.toAppUser());
    _listenToUserChanges();
    Log.hint("User stream initialized");
  }

  void _listenToUserChanges() async {
    final PocketBase pocketbase = await _connectionClient.getConnection();
    Future<void> Function()? userRecordSubscription;

    final authSubscription = pocketbase.authStore.onChange.map((event) {
      final record = event.model;
      if (record == null || record is! RecordModel) return null;
      return record.toAppUser();
    }).listen((user) async {
      // Immediately update stream with current auth state
      _userStreamController.sink.add(user);

      // Cancel previous subscription BEFORE handling logout
      try {
        await userRecordSubscription?.call();
      } on ClientException catch (error) {
        Log.warning("Unsubscribe error (safe to ignore): $error");
      }

      final userId = user?.id;
      if (userId == null) return; // No user = no subscription needed

      // Create new subscription with valid auth
      userRecordSubscription = await pocketbase.collection('users').subscribe(userId, (action) {
        if (action.action == 'update' || action.action == 'delete') {
          _userStreamController.sink.add(action.record?.toAppUser());
        }
      });
    });

    _userStreamController.onCancel = () async {
      await authSubscription.cancel();
      try {
        await userRecordSubscription?.call();
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
