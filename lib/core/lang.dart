import 'package:flutter/widgets.dart';

enum AppLang {
  en,
  ru,
  uz;

  Locale get locale => switch (this) {
        AppLang.en => const Locale('en'),
        AppLang.ru => const Locale('ru'),
        AppLang.uz => const Locale('uz'),
      };

  String get label => switch (this) {
        AppLang.en => 'English',
        AppLang.ru => 'Русский',
        AppLang.uz => "O'zbek",
      };

  String get flag => switch (this) {
        AppLang.en => '🇬🇧',
        AppLang.ru => '🇷🇺',
        AppLang.uz => '🇺🇿',
      };

  static AppLang fromCode(String code) =>
      AppLang.values.firstWhere(
        (l) => l.name == code,
        orElse: () => AppLang.en,
      );
}
