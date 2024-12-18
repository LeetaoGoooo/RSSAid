import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }


  /// Get history records
  List<String> get historyList =>
      _sharedPrefs.getStringList('historyListKey') ?? [];

  /// Add new record at the top of the list
  set record(String url) {
    var historyList = _sharedPrefs.getStringList('historyListKey') ?? [];
    historyList.remove(url);
    historyList.insert(0, url);
    _sharedPrefs.setStringList('historyListKey', historyList);
  }

  set domain(String domain) => _sharedPrefs.setString("RSSHUB", domain);

  String get domain => _sharedPrefs.getString("RSSHUB") ?? "https://rsshub.app";

  List<String> get domains => _sharedPrefs.getStringList("DOMAIN") ?? ["https://rsshub.app"];

  set domains(List<String> domains) => _sharedPrefs.setStringList("DOMAIN", domains);

  /// Save history records after user delete one
  set historyList(List<String> history) =>
      _sharedPrefs.setStringList('historyListKey', history);

  Future<void> removeIfExist(String key) async {
    if (_sharedPrefs.containsKey(key)) {
      await _sharedPrefs.remove(key);
    }
  }

  set rules(String rules) => _sharedPrefs.setString("Rules", rules);

  String get rules => _sharedPrefs.getString("Rules") ?? "";

  set currentParams(String currentParams) =>
      _sharedPrefs.setString("currentParams", currentParams);


  String get currentParams => _sharedPrefs.getString("currentParams") ?? "";

  set defaultParams(String defaultParams) =>
      _sharedPrefs.setString("defaultParams", defaultParams);

  String get defaultParams => _sharedPrefs.getString("defaultParams") ?? "";

  Future<bool> clear() => _sharedPrefs.clear();

  set config(String config) => _sharedPrefs.setString("config", config);

  String get config => _sharedPrefs.getString("config") ?? "";

  bool get accessControl => _sharedPrefs.getBool("accessControl") ?? false;

  set accessControl(bool value) => _sharedPrefs.setBool("accessControl", value);

  String get accessKey => _sharedPrefs.getString("accessKey") ?? "";

  set accessKey(String key) => _sharedPrefs.setString("accessKey", key);
}