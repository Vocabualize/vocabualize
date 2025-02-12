import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/send_password_reset_email_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/sign_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/welcome_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  static const String routeName =
      "${WelcomeScreen.routeName}/${SignScreen.routeName}/ForgotPassword";

  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _sendButtonBlocked = false;
  Timer? _resetBlockTimer;
  final int _seconds = 60;
  late int _secondsLeft;

  Future<void> startBlockedTimer() async {
    setState(() => _sendButtonBlocked = true);
    _resetBlockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft == 0) {
        setState(() => _sendButtonBlocked = false);
        timer.cancel();
        _secondsLeft = _seconds;
      }
    });
  }

  @override
  void initState() {
    setState(() => _secondsLeft = _seconds);
    super.initState();
  }

  @override
  void dispose() {
    _resetBlockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onSendPasswordResetEmailClick(String email) {
      ref.read(sendPasswordResetEmailUseCaseProvider(email));
      startBlockedTimer();
    }

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.extraLargeSpacing,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.s.onboarding_password_reset_title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Dimensions.mediumSpacing),
              Text(
                context.s.onboarding_password_reset_description,
              ),
              const SizedBox(height: Dimensions.mediumSpacing),
              TextField(
                decoration: InputDecoration(
                  label: Text(
                    context.s.onboarding_email,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                controller: _emailController,
              ),
              const SizedBox(height: Dimensions.largeSpacing),
              ElevatedButton(
                onPressed: _sendButtonBlocked
                    ? null
                    : () {
                        onSendPasswordResetEmailClick(
                          _emailController.text,
                        );
                      },
                child: Text(_sendButtonBlocked
                    ? context.s.onboarding_password_reset_wait(_secondsLeft)
                    : context.s.onboarding_password_reset_send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
