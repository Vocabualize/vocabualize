import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/send_verification_email_use_case.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  Timer? reloadTimer;
  bool _sendButtonBlocked = false;
  Timer? _blockTimer;
  final int _seconds = 60;
  late int _secondsLeft;

  void _startReloadTimer() async {
    setState(() => reloadTimer = Timer.periodic(const Duration(seconds: 3), (_) => _reload()));
  }

  // TODO: Implement reload method for verification (also implement verification in general lol)
  void _reload() async {
    // await AuthService.instance.reloadUser().whenComplete(() {
    //   if (FirebaseAuth.instance.currentUser!.emailVerified) {
    //     reloadTimer?.cancel();
    //     context.pushNamed(SelectLanguageScreen.routeName);
    //   }
    // });
  }

  void _resetBlockTimer() {
    _blockTimer?.cancel();
    setState(() => _secondsLeft = _seconds);
  }

  Future<void> _startBlockedTimer() async {
    setState(() => _sendButtonBlocked = true);
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft == 0) {
        setState(() => _sendButtonBlocked = false);
        _resetBlockTimer();
      }
    });
  }

  @override
  void initState() {
    _resetBlockTimer();
    _startReloadTimer();
    super.initState();
  }

  @override
  void dispose() {
    reloadTimer?.cancel();
    _blockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendVerificationEmail = ref.watch(sendVerificationEmailUseCaseProvider);

    Future<void> onSendVerificationEmailClick() async {
      sendVerificationEmail();
      _startBlockedTimer();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: Replace with arb
              Text("Verify your email", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              // TODO: Replace with arb
              const Text(
                "We sent you an email with a link. Please, click on it to verify your email address.",
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _sendButtonBlocked ? null : () => onSendVerificationEmailClick(),
                // TODO: Replace with arb
                child: Text(_sendButtonBlocked
                    ? "Wait $_secondsLeft seconds"
                    : "Resend verification email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
