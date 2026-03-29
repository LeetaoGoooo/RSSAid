import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh')
  ];

  /// No description provided for @notfoundinshare.
  ///
  /// In en, this message translates to:
  /// **'No links detected on sharing'**
  String get notfoundinshare;

  /// No description provided for @notfoundinClipboard.
  ///
  /// In en, this message translates to:
  /// **'No links detected on clipboard'**
  String get notfoundinClipboard;

  /// No description provided for @fromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Import from clipboard'**
  String get fromClipboard;

  /// No description provided for @inputbyKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Import from plain text'**
  String get inputbyKeyboard;

  /// No description provided for @notfound.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get notfound;

  /// No description provided for @addConfig.
  ///
  /// In en, this message translates to:
  /// **'Create configuration'**
  String get addConfig;

  /// No description provided for @submitNewRules.
  ///
  /// In en, this message translates to:
  /// **'Submit new rules'**
  String get submitNewRules;

  /// No description provided for @whichSupport.
  ///
  /// In en, this message translates to:
  /// **'View supported rules'**
  String get whichSupport;

  /// No description provided for @loadRulesFailed.
  ///
  /// In en, this message translates to:
  /// **'Please verify if the rules have been loaded successfully on the config page!'**
  String get loadRulesFailed;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copySuccess;

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Copy Failed!'**
  String get copyFailed;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @inputLinkChecked.
  ///
  /// In en, this message translates to:
  /// **'Enter the link to detect'**
  String get inputLinkChecked;

  /// No description provided for @sure.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get sure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @linkError.
  ///
  /// In en, this message translates to:
  /// **'Empty link'**
  String get linkError;

  /// No description provided for @s2t.
  ///
  /// In en, this message translates to:
  /// **'Convert to Chinese (Traditional)'**
  String get s2t;

  /// No description provided for @t2s.
  ///
  /// In en, this message translates to:
  /// **'Convert to Chinese (Simplified)'**
  String get t2s;

  /// No description provided for @gc.
  ///
  /// In en, this message translates to:
  /// **'General configuration'**
  String get gc;

  /// No description provided for @contentFilter.
  ///
  /// In en, this message translates to:
  /// **'Content filter'**
  String get contentFilter;

  /// No description provided for @caseSensitive.
  ///
  /// In en, this message translates to:
  /// **'Case sensitive'**
  String get caseSensitive;

  /// No description provided for @fullText.
  ///
  /// In en, this message translates to:
  /// **'Show full text'**
  String get fullText;

  /// No description provided for @sci_hub_link.
  ///
  /// In en, this message translates to:
  /// **'Output sci-hub link'**
  String get sci_hub_link;

  /// No description provided for @filtering.
  ///
  /// In en, this message translates to:
  /// **'Filter: Matches (supports regex)'**
  String get filtering;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Title and description'**
  String get filter;

  /// No description provided for @filter_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get filter_title;

  /// No description provided for @filter_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get filter_description;

  /// No description provided for @filter_author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get filter_author;

  /// No description provided for @filter_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get filter_time;

  /// No description provided for @filter_time_hints.
  ///
  /// In en, this message translates to:
  /// **'Number in seconds'**
  String get filter_time_hints;

  /// No description provided for @filterout.
  ///
  /// In en, this message translates to:
  /// **'Filter: Excludes (supports regex)'**
  String get filterout;

  /// No description provided for @filterout_default.
  ///
  /// In en, this message translates to:
  /// **'Title and description'**
  String get filterout_default;

  /// No description provided for @filterout_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get filterout_title;

  /// No description provided for @filterout_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get filterout_description;

  /// No description provided for @filterout_author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get filterout_author;

  /// No description provided for @filter_others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get filter_others;

  /// No description provided for @limit_entries.
  ///
  /// In en, this message translates to:
  /// **'Max entries'**
  String get limit_entries;

  /// No description provided for @limit_entries_hint.
  ///
  /// In en, this message translates to:
  /// **'Number of entries'**
  String get limit_entries_hint;

  /// No description provided for @access_control.
  ///
  /// In en, this message translates to:
  /// **'Access Control'**
  String get access_control;

  /// No description provided for @csAts.
  ///
  /// In en, this message translates to:
  /// **'Convert Chinese (Simplified) and Chinese (Traditional)'**
  String get csAts;

  /// No description provided for @output_format.
  ///
  /// In en, this message translates to:
  /// **'Output format'**
  String get output_format;

  /// No description provided for @rule_only_once.
  ///
  /// In en, this message translates to:
  /// **'Only works for current rules'**
  String get rule_only_once;

  /// No description provided for @reset_config_hint.
  ///
  /// In en, this message translates to:
  /// **'Configuration reset successfully!'**
  String get reset_config_hint;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @save_config_hint.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved!'**
  String get save_config_hint;

  /// No description provided for @update_rule.
  ///
  /// In en, this message translates to:
  /// **'Update Rules'**
  String get update_rule;

  /// No description provided for @loading_hint.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading_hint;

  /// No description provided for @user_manual.
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get user_manual;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @common.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get common;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @refreshRules.
  ///
  /// In en, this message translates to:
  /// **'Refresh Rules'**
  String get refreshRules;

  /// No description provided for @refreshingRules.
  ///
  /// In en, this message translates to:
  /// **'Refreshing Rules...'**
  String get refreshingRules;

  /// No description provided for @refreshRulesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rules updated successfully!'**
  String get refreshRulesSuccess;

  /// No description provided for @refreshRulesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update rules.'**
  String get refreshRulesFailed;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
