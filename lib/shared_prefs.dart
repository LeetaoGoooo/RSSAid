import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }


  /// Get history records
  List<String> get historyList => _sharedPrefs.getStringList('historyListKey') ?? [];

  /// Add new record at the top of the list
  set record(String url)  {
    var historyList = _sharedPrefs.getStringList('historyListKey') ?? [];
    historyList.remove(url);
    historyList.insert(0, url);
    _sharedPrefs.setStringList('historyListKey', historyList);
  }

  /// Save history records after user delete one
  set historyList(List<String> history) => _sharedPrefs.setStringList('historyListKey', history);

  Future<void> removeIfExist(String key) async {
    if (_sharedPrefs.containsKey(key)) {
      await _sharedPrefs.remove(key);
    }
  }

  set rules(String rules) => _sharedPrefs.setString("Rules", rules);

  String get rules => _sharedPrefs.getString("Rules") ?? "";
}
