import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// App bar title on the main screen.
  ///
  /// In en, this message translates to:
  /// **'TOP SPEED'**
  String get appTitle;

  /// GPS speed source chip label.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get sourceGps;

  /// Accelerometer speed source chip label.
  ///
  /// In en, this message translates to:
  /// **'ACCELEROMETER'**
  String get sourceAccelerometer;

  /// Label for the top-speed stat tile.
  ///
  /// In en, this message translates to:
  /// **'TOP SPEED'**
  String get labelTopSpeed;

  /// Label for the average speed stat tile.
  ///
  /// In en, this message translates to:
  /// **'AVG SPEED'**
  String get labelAvgSpeed;

  /// Label for the session duration stat tile.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get labelDuration;

  /// Start session button.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get btnStart;

  /// Stop session button.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get btnStop;

  /// History screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get historyTitle;

  /// Placeholder when there are no saved sessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.\nStart your first session!'**
  String get historyEmpty;

  /// End-session sheet header.
  ///
  /// In en, this message translates to:
  /// **'SESSION ENDED'**
  String get sessionEnded;

  /// Label above the comment text field.
  ///
  /// In en, this message translates to:
  /// **'ADD A NOTE'**
  String get addNote;

  /// Hint text inside the comment field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning run, downhill section…'**
  String get noteHint;

  /// Discard session button.
  ///
  /// In en, this message translates to:
  /// **'DISCARD'**
  String get btnDiscard;

  /// Save session button.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get btnSave;

  /// Language picker sheet title.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Activity type picker label.
  ///
  /// In en, this message translates to:
  /// **'SELECT ACTIVITY'**
  String get selectActivity;

  /// No description provided for @activityRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get activityRun;

  /// No description provided for @activityBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get activityBike;

  /// No description provided for @activitySki.
  ///
  /// In en, this message translates to:
  /// **'Ski'**
  String get activitySki;

  /// No description provided for @activitySurf.
  ///
  /// In en, this message translates to:
  /// **'Surf'**
  String get activitySurf;

  /// No description provided for @activityOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get activityOther;

  /// Text shown at the end of the start countdown.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get countdownGo;

  /// Personal records screen title.
  ///
  /// In en, this message translates to:
  /// **'RECORDS'**
  String get recordsTitle;

  /// Section header for all-time records.
  ///
  /// In en, this message translates to:
  /// **'ALL TIME'**
  String get recordAllTime;

  /// Placeholder when no sessions have been saved.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get recordNoData;

  /// Session detail screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'SESSION'**
  String get sessionDetailTitle;

  /// Share button label.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get btnShare;

  /// Speed alert bottom sheet title.
  ///
  /// In en, this message translates to:
  /// **'SPEED ALERT'**
  String get alertTitle;

  /// Speed alert disabled label.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get alertOff;

  /// Hint inside the alert speed input field.
  ///
  /// In en, this message translates to:
  /// **'Enter speed to trigger alert'**
  String get alertHint;

  /// Label shown when speed alert is active/set.
  ///
  /// In en, this message translates to:
  /// **'ALERT'**
  String get alertActive;

  /// No description provided for @navTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get navTrack;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'UNITS'**
  String get settingsUnits;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsLanguage;

  /// No description provided for @settingsAlert.
  ///
  /// In en, this message translates to:
  /// **'SPEED ALERT'**
  String get settingsAlert;

  /// No description provided for @settingsAlertOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsAlertOff;

  /// No description provided for @settingsAlertActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get settingsAlertActive;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
