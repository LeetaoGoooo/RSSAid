// @dart=2.9
import 'dart:convert';

import 'package:rssaid/common/common.dart';
import 'package:rssaid/models/radar_config.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class ConfigDialog extends StatefulWidget {
  @override
  _ConfigStateDialog createState() => new _ConfigStateDialog();
}

class _ConfigStateDialog extends State<ConfigDialog> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _filterController = new TextEditingController();
  TextEditingController _filterTitleController = new TextEditingController();
  TextEditingController _filterDescriptionController =
      new TextEditingController();
  TextEditingController _filterAuthorController = new TextEditingController();
  TextEditingController _filterTimeController = new TextEditingController();
  TextEditingController _filterOutController = new TextEditingController();
  TextEditingController _filterTitleOutController = new TextEditingController();
  TextEditingController _filterDescriptionOutController =
      new TextEditingController();
  TextEditingController _filterAuthorOutController =
      new TextEditingController();
  bool _caseSensitive = false;
  TextEditingController _countController = new TextEditingController();
  TextEditingController _accessController = new TextEditingController();
  bool _countValidate = true;
  bool _timeValidate = true;
  bool _mode = false;
  bool _outScihub = false;
  Language _selectLanguage;
  List<Language> languages = <Language>[
    Language("s2t", "简体到繁体"),
    Language("t2s", "繁体到简体"),
  ];
  RssFormat _selectRssFormat;
  List<RssFormat> rssFormats = <RssFormat>[
    RssFormat(".atom", "Atom"),
    RssFormat(".rss", "RSS 2.0")
  ];
  bool _onlyOnce = true; // 配置只对当前生效

  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("通用配置"),
      ),
      body: SingleChildScrollView(
          child: Card(
              margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 0,
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 16),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "内容筛选",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[400]),
                            ),
                            ListTile(
                              leading: Text("是否大小写敏感"),
                              trailing: Switch(
                                  value: _caseSensitive,
                                  onChanged: (value) {
                                    setState(() {
                                      _caseSensitive = value;
                                    });
                                  }),
                            ),
                            ListTile(
                              leading: Text("全文输出"),
                              trailing: Switch(
                                  value: _outScihub,
                                  onChanged: (value) {
                                    setState(() {
                                      _outScihub = value;
                                    });
                                  }),
                            ),
                            ListTile(
                              leading: Text("输出 Sci-hub 链接"),
                              trailing: Switch(
                                  value: _mode,
                                  onChanged: (value) {
                                    setState(() {
                                      _mode = value;
                                    });
                                  }),
                            ),
                            Text("匹配符合条件的内容(支持正则表达式)",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[400])),
                            TextFormField(
                              autofocus: true,
                              controller: _filterController,
                              decoration: InputDecoration(
                                  labelText: "标题和描述", icon: Icon(Icons.list)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterTitleController,
                              decoration: InputDecoration(
                                  labelText: "标题", icon: Icon(Icons.title)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterDescriptionController,
                              decoration: InputDecoration(
                                  labelText: "描述",
                                  icon: Icon(Icons.description)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterAuthorController,
                              decoration: InputDecoration(
                                  labelText: "作者", icon: Icon(Icons.person)),
                            ),
                            TextFormField(
                                autofocus: true,
                                controller: _filterTimeController,
                                decoration: InputDecoration(
                                  labelText: "时间",
                                  hintText: "仅支持数字，单位为秒",
                                  errorText: _timeValidate ? null : "仅支持数字",
                                  icon: Icon(Icons.timeline),
                                ),
                                onChanged: (value) {
                                  if (value.trim().isEmpty) {
                                    setState(() {
                                      _timeValidate = true;
                                    });
                                    return null;
                                  }
                                  setState(() {
                                    _timeValidate = Common.isNumeric(value);
                                  });
                                },
                                validator: (v) {
                                  if (v.trim().isEmpty) {
                                    return null;
                                  }
                                  return Common.isNumeric(v)
                                      ? null
                                      : "时间仅支持为数字";
                                }),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "过滤符合条件的内容(支持正则表达式)",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[400]),
                              ),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterOutController,
                              decoration: InputDecoration(
                                  labelText: "标题和描述", icon: Icon(Icons.list)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterTitleOutController,
                              decoration: InputDecoration(
                                  labelText: "标题", icon: Icon(Icons.title)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterDescriptionOutController,
                              decoration: InputDecoration(
                                  labelText: "描述",
                                  icon: Icon(Icons.description)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterAuthorOutController,
                              decoration: InputDecoration(
                                  labelText: "作者", icon: Icon(Icons.person)),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "其他",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[400]),
                                )),
                            TextFormField(
                                autofocus: true,
                                controller: _countController,
                                decoration: InputDecoration(
                                    labelText: "条数限制",
                                    errorText: _countValidate ? null : "仅支持数字",
                                    icon: Icon(Icons.filter_9_plus)),
                                onChanged: (v) {
                                  if (v.trim().isEmpty) {
                                    setState(() {
                                      _countValidate = true;
                                    });
                                    return null;
                                  }
                                  setState(() {
                                    _countValidate = Common.isNumeric(v);
                                  });
                                },
                                validator: (v) {
                                  if (v.trim().isEmpty) {
                                    return null;
                                  }
                                  return Common.isNumeric(v) ? null : "仅支持数字";
                                }),
                            TextFormField(
                                autofocus: true,
                                controller: _accessController,
                                decoration: InputDecoration(
                                    labelText: "访问控制",
                                    icon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.help),
                                        onPressed: () {
                                          Common.launchInBrowser(
                                              "https://docs.rsshub.app/install/#pei-zhi-fang-wen-kong-zhi-pei-zhi");
                                        }))),
                            DropdownButtonFormField<Language>(
                              decoration: InputDecoration(
                                icon: Icon(Icons.language),
                              ),
                              hint: Text("中文简繁体转换"),
                              value: _selectLanguage,
                              onChanged: (value) {
                                setState(() {
                                  _selectLanguage = value;
                                });
                              },
                              items: languages.map((Language language) {
                                return DropdownMenuItem<Language>(
                                  value: language,
                                  child: Text(language.name),
                                );
                              }).toList(),
                            ),
                            DropdownButtonFormField<RssFormat>(
                              decoration: InputDecoration(
                                icon: Icon(Icons.rss_feed),
                              ),
                              hint: Text("输出格式"),
                              value: _selectRssFormat,
                              onChanged: (value) {
                                setState(() {
                                  _selectRssFormat = value;
                                });
                              },
                              items: rssFormats.map((RssFormat rssFormat) {
                                return DropdownMenuItem<RssFormat>(
                                  value: rssFormat,
                                  child: Text(rssFormat.name),
                                );
                              }).toList(),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _onlyOnce,
                                    onChanged: (value) {
                                      setState(() => _onlyOnce = value);
                                    },
                                    activeColor: Colors.orange,
                                  ),
                                  Text("仅对本次规则生效")
                                ]),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton.icon(
                                  icon: Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  onPressed: _saveConfig,
                                  label: Text(
                                    "保存",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: Colors.orange,
                                ),
                                FlatButton.icon(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final SharedPreferences prefs =
                                        await _prefs;
                                    prefs.clear();
                                    _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Text('重置配置成功!')));
                                  },
                                  label: Text(
                                    "重置",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: Colors.orange,
                                ),
                              ],
                            )
                          ]))))),
    );
  }

  _saveConfig() async {
    if (_formKey.currentState.validate()) {
      await _parseConfig();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating, content: Text('保存配置成功!')));
    }
  }

  _parseConfig() async {
    final SharedPreferences prefs = await _prefs;
    RadarConfig radarConfig = new RadarConfig();
    var params = "?";
    // 输出格式
    if (_selectRssFormat != null) {
      params += _selectRssFormat.value;
      radarConfig.format = _selectRssFormat;
    }
    // 是否大小写敏感
    if (_caseSensitive) {
      params += "filter_case_sensitive=true&";
      radarConfig.filterCaseSensitive = true;
    }
    // 输出 Sci-hub 链接
    if (_outScihub) {
      params += "scihub=1&";
      radarConfig.scihub = _outScihub;
    }
    // 中文简繁体转换
    // ignore: unnecessary_null_comparison
    if (_selectLanguage != null) {
      params += "opencc=${_selectLanguage.value}&";
      radarConfig.opencc = _selectLanguage;
    }
    // 是否全文输出
    if (_mode) {
      params += "mode=fulltext&";
      radarConfig.mode = true;
    }
    // 条数限制
    if (_countController.text.trim().isNotEmpty) {
      params += "limit=${_countController.text.trim()}&";
      radarConfig.limit = _countController.text.trim();
    }

    // 访问控制
    if (_accessController.text.trim().isNotEmpty) {
      params += "${_accessController.text.trim()}&";
      radarConfig.access = _accessController.text.trim();
    }

    // 匹配标题和描述
    if (_filterController.text.trim().isNotEmpty) {
      params += "filter=${_filterController.text.trim()}&";
      radarConfig.filter = _filterController.text.trim();
    }

    if (_filterTitleController.text.trim().isNotEmpty) {
      params += "filter_title=${_filterTitleController.text.trim()}&";
      radarConfig.filterTitle = _filterTitleController.text.trim();
    }
    if (_filterDescriptionController.text.trim().isNotEmpty) {
      params +=
          "filter_description=${_filterDescriptionController.text.trim()}&";
      radarConfig.filterDescription = _filterDescriptionController.text.trim();
    }
    // 匹配作者
    // ignore: null_aware_in_condition
    if (_filterAuthorController.text.trim().isNotEmpty) {
      params += "filter_author=${_filterAuthorController.text.trim()}&";
      radarConfig.filterAuthor = _filterAuthorController.text.trim();
    }
    // 匹配时间
    // ignore: null_aware_in_condition
    if (_filterTimeController.text.trim().isNotEmpty) {
      params += "filter_time=${_filterTimeController.text.trim()}&";
      radarConfig.filterTime = _filterTimeController.text.trim();
    }

    // 过滤标题和内容
    // ignore: null_aware_in_condition
    if (_filterOutController.text.trim().isNotEmpty) {
      params += "filterout=${_filterOutController.text.trim()}&";
      radarConfig.filterOut = _filterOutController.text.trim();
    }
    // ignore: null_aware_in_condition
    if (_filterTitleOutController.text.trim().isNotEmpty) {
      params += "filterout_title=${_filterTitleOutController.text.trim()}&";
      radarConfig.filterOutTitle = _filterTitleOutController.text.trim();
    }
    // ignore: null_aware_in_condition
    if (_filterDescriptionOutController.text.trim().isNotEmpty) {
      params +=
          "filterout_description=${_filterDescriptionOutController.text.trim()}&";
      radarConfig.filterOutDescription =
          _filterDescriptionOutController.text.trim();
    }

    // 过滤作者
    // ignore: null_aware_in_condition
    if (_filterAuthorOutController.text.trim().isNotEmpty) {
      params += "filterout_author=${_filterAuthorOutController.text.trim()}&";
      radarConfig.filterOutAuthor = _filterAuthorOutController.text.trim();
    }
    if (params.endsWith("&")) {
      params = params.substring(0, params.length - 1);
    }
    // 全局配置或者本次配置
    if (_onlyOnce) {
      prefs.setString("currentParams", params);
    } else {
      prefs.setString("defaultParams", params);
      prefs.setString("config", json.encode(radarConfig.toJson()));
    }
  }

  _loadConfig() async {
    final SharedPreferences prefs = await _prefs;
    if (!prefs.containsKey("config")) {
      return;
    }
    String configStr = prefs.getString("config");
    RadarConfig radarConfig = RadarConfig.fromJson(json.decode(configStr));
    setState(() {
      // 其他
      _selectLanguage = radarConfig.opencc;
      _selectRssFormat = radarConfig.format;
      // ignore: unnecessary_null_comparison
      _caseSensitive = radarConfig.filterCaseSensitive != null
          ? radarConfig.filterCaseSensitive
          : false;
      // ignore: unnecessary_null_comparison
      _mode = radarConfig.mode != null ? radarConfig.mode : false;
      // ignore: unnecessary_null_comparison
      _outScihub = radarConfig.scihub != null ? radarConfig.scihub : false;
      _countController.text = radarConfig.limit;
      _accessController.text = radarConfig.access;

      // 匹配
      _filterController.text = radarConfig.filter;
      _filterAuthorController.text = radarConfig.filterAuthor;
      _filterDescriptionController.text = radarConfig.filterDescription;
      _filterTitleController.text = radarConfig.filterTitle;
      _filterTimeController.text = radarConfig.filterTime;

      // 过滤
      _filterOutController.text = radarConfig.filterOut;
      _filterTitleOutController.text = radarConfig.filterOutTitle;
      _filterDescriptionOutController.text = radarConfig.filterOutDescription;
      _filterAuthorOutController.text = radarConfig.filterOutAuthor;
    });
  }
}
