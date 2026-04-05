// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'МАКС. СКОРОСТЬ';

  @override
  String get sourceGps => 'GPS';

  @override
  String get sourceAccelerometer => 'АКСЕЛЕРОМЕТР';

  @override
  String get labelTopSpeed => 'МАКС. СКОРОСТЬ';

  @override
  String get labelAvgSpeed => 'СРЕДНЯЯ';

  @override
  String get labelDuration => 'ДЛИТЕЛЬНОСТЬ';

  @override
  String get btnStart => 'СТАРТ';

  @override
  String get btnStop => 'СТОП';

  @override
  String get historyTitle => 'ИСТОРИЯ';

  @override
  String get historyEmpty => 'Сессий пока нет.\nНачните первую сессию!';

  @override
  String get sessionEnded => 'СЕССИЯ ЗАВЕРШЕНА';

  @override
  String get addNote => 'ДОБАВИТЬ ЗАМЕТКУ';

  @override
  String get noteHint => 'напр. Утренняя пробежка, спуск с горы…';

  @override
  String get btnDiscard => 'ОТМЕНА';

  @override
  String get btnSave => 'СОХРАНИТЬ';

  @override
  String get chooseLanguage => 'Выберите язык';

  @override
  String get selectActivity => 'ВИД АКТИВНОСТИ';

  @override
  String get activityRun => 'Бег';

  @override
  String get activityBike => 'Велосипед';

  @override
  String get activitySki => 'Лыжи';

  @override
  String get activitySurf => 'Сёрфинг';

  @override
  String get activityOther => 'Другое';

  @override
  String get countdownGo => 'ВПЕРЁД!';

  @override
  String get recordsTitle => 'РЕКОРДЫ';

  @override
  String get recordAllTime => 'ЗА ВСЁ ВРЕМЯ';

  @override
  String get recordNoData => 'Нет данных';

  @override
  String get sessionDetailTitle => 'СЕССИЯ';

  @override
  String get btnShare => 'ПОДЕЛИТЬСЯ';

  @override
  String get alertTitle => 'СИГНАЛ СКОРОСТИ';

  @override
  String get alertOff => 'ВЫКЛ';

  @override
  String get alertHint => 'Введите скорость для сигнала';

  @override
  String get alertActive => 'СИГНАЛ';

  @override
  String get navTrack => 'Трекер';

  @override
  String get navHistory => 'История';

  @override
  String get navRecords => 'Рекорды';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'НАСТРОЙКИ';

  @override
  String get settingsUnits => 'ЕДИНИЦЫ';

  @override
  String get settingsLanguage => 'ЯЗЫК';

  @override
  String get settingsAlert => 'СИГНАЛ СКОРОСТИ';

  @override
  String get settingsAlertOff => 'Выкл.';

  @override
  String get settingsAlertActive => 'Активен';

  @override
  String get settingsAbout => 'О ПРИЛОЖЕНИИ';

  @override
  String get settingsVersion => 'Версия';
}
