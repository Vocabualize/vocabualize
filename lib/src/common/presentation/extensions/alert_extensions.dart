import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

extension AlertExtensions on Alert {
  Color getColor() {
    return switch (type) {
      AlertType.critical => const Color(0xFF440000),
      AlertType.warning => const Color(0xFF584A02),
      AlertType.info => const Color(0xFF004401),
      AlertType.hint => const Color(0xFF002844),
    };
  }

  String? getLocalTitle(BuildContext context) {
    return _isGerman(context) ? titleDe ?? title : title;
  }

  String getLocalMessage(BuildContext context) {
    return _isGerman(context) ? messageDe ?? message : message;
  }
}

bool _isGerman(BuildContext context) => context.s.localeName == "de";
