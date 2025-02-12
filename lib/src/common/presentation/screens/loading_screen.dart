import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

const _cancelButtonDelay = Duration(seconds: 3);
const _animationDuration = Duration(seconds: 1);

class LoadingScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  const LoadingScreen({this.onCancel, super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool showCancelButton = false;

  @override
  void initState() {
    super.initState();

    if (widget.onCancel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(_cancelButtonDelay);
        if (mounted) setState(() => showCancelButton = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
            const Spacer(),
            const CircularProgressIndicator.adaptive(),
            const Spacer(),
            AnimatedOpacity(
              opacity: showCancelButton ? 1 : 0,
              duration: _animationDuration,
              child: OutlinedButton(
                onPressed: widget.onCancel,
                child: Text(context.s.common_cancel),
              ),
            ),
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
          ],
        ),
      ),
    );
  }
}
