// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get notfoundinshare => 'No links detected on sharing';

  @override
  String get notfoundinClipboard => 'No links detected on clipboard';

  @override
  String get fromClipboard => 'Import from clipboard';

  @override
  String get inputbyKeyboard => 'Import from plain text';

  @override
  String get notfound => 'Not Found';

  @override
  String get addConfig => 'Create configuration';

  @override
  String get submitNewRules => 'Submit new rules';

  @override
  String get whichSupport => 'View supported rules';

  @override
  String get loadRulesFailed =>
      'Please verify if the rules have been loaded successfully on the config page!';

  @override
  String get copy => 'Copy';

  @override
  String get copySuccess => 'Copied!';

  @override
  String get copyFailed => 'Copy Failed!';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get clear => 'Clear';

  @override
  String get inputLinkChecked => 'Enter the link to detect';

  @override
  String get sure => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get linkError => 'Empty link';

  @override
  String get s2t => 'Convert to Chinese (Traditional)';

  @override
  String get t2s => 'Convert to Chinese (Simplified)';

  @override
  String get gc => 'General configuration';

  @override
  String get contentFilter => 'Content filter';

  @override
  String get caseSensitive => 'Case sensitive';

  @override
  String get fullText => 'Show full text';

  @override
  String get sci_hub_link => 'Output sci-hub link';

  @override
  String get filtering => 'Filter: Matches (supports regex)';

  @override
  String get filter => 'Title and description';

  @override
  String get filter_title => 'Title';

  @override
  String get filter_description => 'Description';

  @override
  String get filter_author => 'Author';

  @override
  String get filter_time => 'Time';

  @override
  String get filter_time_hints => 'Number in seconds';

  @override
  String get filterout => 'Filter: Excludes (supports regex)';

  @override
  String get filterout_default => 'Title and description';

  @override
  String get filterout_title => 'Title';

  @override
  String get filterout_description => 'Description';

  @override
  String get filterout_author => 'Author';

  @override
  String get filter_others => 'Others';

  @override
  String get limit_entries => 'Max entries';

  @override
  String get limit_entries_hint => 'Number of entries';

  @override
  String get access_control => 'Access Control';

  @override
  String get csAts => 'Convert Chinese (Simplified) and Chinese (Traditional)';

  @override
  String get output_format => 'Output format';

  @override
  String get rule_only_once => 'Only works for current rules';

  @override
  String get reset_config_hint => 'Configuration reset successfully!';

  @override
  String get reset => 'Reset';

  @override
  String get save_config_hint => 'Configuration saved!';

  @override
  String get update_rule => 'Update Rules';

  @override
  String get loading_hint => 'Loading...';

  @override
  String get user_manual => 'User Manual';

  @override
  String get settings => 'Settings';

  @override
  String get common => 'General';

  @override
  String get about => 'About';

  @override
  String get refreshRules => 'Refresh Rules';

  @override
  String get refreshingRules => 'Refreshing Rules...';

  @override
  String get refreshRulesSuccess => 'Rules updated successfully!';

  @override
  String get refreshRulesFailed => 'Failed to update rules.';

  @override
  String get preview => 'Preview';
}
