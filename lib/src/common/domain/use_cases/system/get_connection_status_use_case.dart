import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final _internetConnectionCheckerProvider = Provider<InternetConnection>(
  (ref) => InternetConnection(),
);

final getConnectionStatusUseCaseProvider = StreamProvider<bool>((ref) async* {
  final internetConnection = ref.read(_internetConnectionCheckerProvider);

  final isConnected = await internetConnection.hasInternetAccess;
  yield isConnected;

  yield* internetConnection.onStatusChange.map(
    (status) => status == InternetStatus.connected,
  );
});
