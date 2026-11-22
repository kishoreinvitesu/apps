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

  /// No description provided for @designOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Design of the day'**
  String get designOfTheDay;

  /// No description provided for @designOfTheDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Today\'s original geometric sample.'**
  String get designOfTheDayDescription;

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

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search designs or keywords'**
  String get exploreSearchHint;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @exploreNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No designs found'**
  String get exploreNoResultsTitle;

  /// No description provided for @exploreNoResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search or filters.'**
  String get exploreNoResultsDescription;

  /// No description provided for @sampleContentNotice.
  ///
  /// In en, this message translates to:
  /// **'These are original geometric samples. Region and tradition are unassigned while content review is pending.'**
  String get sampleContentNotice;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get pendingReview;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @noReviewedCategories.
  ///
  /// In en, this message translates to:
  /// **'No reviewed region or tradition categories are available yet.'**
  String get noReviewedCategories;

  /// No description provided for @noDotGridCategories.
  ///
  /// In en, this message translates to:
  /// **'No dot-grid categories are available yet.'**
  String get noDotGridCategories;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @tradition.
  ///
  /// In en, this message translates to:
  /// **'Tradition'**
  String get tradition;

  /// No description provided for @technique.
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get technique;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @dotGrid.
  ///
  /// In en, this message translates to:
  /// **'Dot grid'**
  String get dotGrid;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @techniqueGeometricLines.
  ///
  /// In en, this message translates to:
  /// **'Geometric lines'**
  String get techniqueGeometricLines;

  /// No description provided for @favoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get favoriteRemove;

  /// No description provided for @favoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favourites'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites'**
  String get favoriteRemoved;

  /// No description provided for @favoriteUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Your favourite could not be updated.'**
  String get favoriteUpdateError;

  /// No description provided for @catalogLoadError.
  ///
  /// In en, this message translates to:
  /// **'The design library could not be loaded.'**
  String get catalogLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @thumbnailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail unavailable'**
  String get thumbnailUnavailable;

  /// No description provided for @savedFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourite designs'**
  String get savedFavoritesTitle;

  /// No description provided for @savedCreationsComing.
  ///
  /// In en, this message translates to:
  /// **'My Creations will be available in a later update.'**
  String get savedCreationsComing;

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

  /// No description provided for @designDetails.
  ///
  /// In en, this message translates to:
  /// **'Design details'**
  String get designDetails;

  /// No description provided for @learnDesign.
  ///
  /// In en, this message translates to:
  /// **'Learn design'**
  String get learnDesign;

  /// No description provided for @previewLesson.
  ///
  /// In en, this message translates to:
  /// **'Vector preview'**
  String get previewLesson;

  /// No description provided for @sampleLessonNotice.
  ///
  /// In en, this message translates to:
  /// **'This is an original vector preview, not a culturally verified lesson.'**
  String get sampleLessonNotice;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @drawNextStroke.
  ///
  /// In en, this message translates to:
  /// **'Draw the next stroke'**
  String get drawNextStroke;

  /// No description provided for @lessonComplete.
  ///
  /// In en, this message translates to:
  /// **'Preview complete'**
  String get lessonComplete;

  /// No description provided for @metadataUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned until content review'**
  String get metadataUnassigned;

  /// No description provided for @practiceDesign.
  ///
  /// In en, this message translates to:
  /// **'Practise / Trace'**
  String get practiceDesign;

  /// No description provided for @practiceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Practice is coming soon'**
  String get practiceComingSoon;

  /// No description provided for @practiceComingSoonDescription.
  ///
  /// In en, this message translates to:
  /// **'This guide is ready for the tracing tools planned for a future update.'**
  String get practiceComingSoonDescription;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @createPatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a pattern'**
  String get createPatternTitle;

  /// No description provided for @createPatternSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a starting pattern and adjust it with a live vector preview.'**
  String get createPatternSubtitle;

  /// No description provided for @patternType.
  ///
  /// In en, this message translates to:
  /// **'Pattern type'**
  String get patternType;

  /// No description provided for @radialFlower.
  ///
  /// In en, this message translates to:
  /// **'Radial flower'**
  String get radialFlower;

  /// No description provided for @dotGridDiamonds.
  ///
  /// In en, this message translates to:
  /// **'Dot-grid diamonds'**
  String get dotGridDiamonds;

  /// No description provided for @petals.
  ///
  /// In en, this message translates to:
  /// **'Petals'**
  String get petals;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radius;

  /// No description provided for @petalWidth.
  ///
  /// In en, this message translates to:
  /// **'Petal width'**
  String get petalWidth;

  /// No description provided for @gridSize.
  ///
  /// In en, this message translates to:
  /// **'Grid size'**
  String get gridSize;

  /// No description provided for @dotLayout.
  ///
  /// In en, this message translates to:
  /// **'Dot layout'**
  String get dotLayout;

  /// No description provided for @layoutSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get layoutSquare;

  /// No description provided for @layoutStaggered.
  ///
  /// In en, this message translates to:
  /// **'Staggered'**
  String get layoutStaggered;

  /// No description provided for @layoutDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get layoutDiamond;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @creatorPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'This preview is generated from editable pattern parameters. Saving and export are planned for a later update.'**
  String get creatorPreviewNotice;

  /// No description provided for @dotGridSizeHelper.
  ///
  /// In en, this message translates to:
  /// **'Traditional Muggu and Kolam patterns typically use 5×5, 7×7 or 9×9 dot grids.'**
  String get dotGridSizeHelper;
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
