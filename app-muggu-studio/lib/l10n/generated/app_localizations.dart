import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Muggu Studio'**
  String get appName;

  /// No description provided for @brandLine.
  ///
  /// In en, this message translates to:
  /// **'Rangoli • Kolam • Muggu • Indian Floor Art'**
  String get brandLine;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your language preference could not be saved.'**
  String get languageSaveError;

  /// No description provided for @dailyMuggu.
  ///
  /// In en, this message translates to:
  /// **'Daily Muggu'**
  String get dailyMuggu;

  /// No description provided for @dailyMugguDescription.
  ///
  /// In en, this message translates to:
  /// **'A little inspiration for your creative tradition.'**
  String get dailyMugguDescription;

  /// No description provided for @learnThisDesign.
  ///
  /// In en, this message translates to:
  /// **'Learn this design'**
  String get learnThisDesign;

  /// No description provided for @createYourOwn.
  ///
  /// In en, this message translates to:
  /// **'Create your own'**
  String get createYourOwn;

  /// No description provided for @journeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Make something meaningful'**
  String get journeyTitle;

  /// No description provided for @chooseYourPath.
  ///
  /// In en, this message translates to:
  /// **'Choose your path'**
  String get chooseYourPath;

  /// No description provided for @journeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse beautiful designs. Learn every step. Create your own.'**
  String get journeyDescription;

  /// No description provided for @exploreDesigns.
  ///
  /// In en, this message translates to:
  /// **'Explore designs'**
  String get exploreDesigns;

  /// No description provided for @exploreDesignsDescription.
  ///
  /// In en, this message translates to:
  /// **'Find a pattern to begin with.'**
  String get exploreDesignsDescription;

  /// No description provided for @openCreator.
  ///
  /// In en, this message translates to:
  /// **'Open the creator'**
  String get openCreator;

  /// No description provided for @openCreatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Bring your own idea to life.'**
  String get openCreatorDescription;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your design library is taking shape'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Original Muggu, Kolam and Rangoli designs will appear here.'**
  String get exploreEmptyDescription;

  /// No description provided for @createEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your creative space is coming'**
  String get createEmptyTitle;

  /// No description provided for @createEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Soon you can draw, practise and save your own designs here.'**
  String get createEmptyDescription;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your favourite designs and creations will be collected here.'**
  String get savedEmptyDescription;

  /// No description provided for @languageMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageMenuLabel;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get telugu;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;
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
      <String>['en', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
