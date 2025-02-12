import 'package:flutter/material.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

extension LanguageExtensions on Language {
  String localName(BuildContext context) {
    return switch (context.s.localeName) {
      "de" => nameDe,
      "es" => nameEs,
      _ => name,
    };
  }
}
