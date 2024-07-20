import 'dart:convert';

import 'package:oktoast/oktoast.dart';
import 'package:rssaid/common/common.dart';
import 'package:rssaid/models/radar_config.dart';
import 'package:flutter/material.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ConfigDialog extends StatefulWidget {
  @override
  _ConfigStateDialog createState() => new _ConfigStateDialog();
}

class _ConfigStateDialog extends State<ConfigDialog> {
  final _formKey = new GlobalKey<FormState>();
  final SharedPrefs prefs = SharedPrefs();
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
  String _selectLanguage = "s2t";
  RssFormat? _selectRssFormat;
  List<RssFormat> rssFormats = <RssFormat>[
    RssFormat(".atom", "Atom"),
    RssFormat(".rss", "RSS 2.0")
  ];
  bool _onlyOnce = true; // 配置只对当前生效

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.gc),
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
                              AppLocalizations.of(context)!.contentFilter,
                              style: TextStyle(
                                  fontSize: 12),
                            ),
                            ListTile(
                              leading: Text(AppLocalizations.of(context)!.caseSensitive),
                              trailing: Switch(
                                  value: _caseSensitive,
                                  onChanged: (value) {
                                    setState(() {
                                      _caseSensitive = value;
                                    });
                                  }),
                            ),
                            ListTile(
                              leading: Text(AppLocalizations.of(context)!.fullText),
                              trailing: Switch(
                                  value: _mode,
                                  onChanged: (value) {
                                    setState(() {
                                      _mode = value;
                                    });
                                  }),
                            ),
                            ListTile(
                              leading: Text(AppLocalizations.of(context)!.sci_hub_link),
                              trailing: Switch(
                                  value: _outScihub,
                                  onChanged: (value) {
                                    setState(() {
                                      _outScihub = value;
                                    });
                                  }),
                            ),
                            Text(AppLocalizations.of(context)!.filtering,
                                style: TextStyle(
                                    fontSize: 12)),
                            TextFormField(
                              autofocus: true,
                              controller: _filterController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filter, icon: Icon(Icons.list)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterTitleController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filter_title, icon: Icon(Icons.title)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterDescriptionController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filter_description,
                                  icon: Icon(Icons.description)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterAuthorController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filter_author, icon: Icon(Icons.person)),
                            ),
                            TextFormField(
                                autofocus: true,
                                controller: _filterTimeController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filter_time,
                                  hintText: AppLocalizations.of(context)!.filter_time_hints,
                                  errorText: _timeValidate ? null : AppLocalizations.of(context)!.limit_entries_hint,
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
                                  if (v!.trim().isEmpty) {
                                    return null;
                                  }
                                  return Common.isNumeric(v)
                                      ? null
                                      : AppLocalizations.of(context)!.limit_entries_hint;
                                }),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                AppLocalizations.of(context)!.filterout,
                                style: TextStyle(
                                    fontSize: 12),
                              ),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterOutController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filterout_default, icon: Icon(Icons.list)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterTitleOutController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filterout_title, icon: Icon(Icons.title)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterDescriptionOutController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filter_description,
                                  icon: Icon(Icons.description)),
                            ),
                            TextFormField(
                              autofocus: true,
                              controller: _filterAuthorOutController,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.filterout_author, icon: Icon(Icons.person)),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  AppLocalizations.of(context)!.filter_others,
                                  style: TextStyle(
                                      fontSize: 12),
                                )),
                            TextFormField(
                                autofocus: true,
                                controller: _countController,
                                decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.limit_entries,
                                    errorText: _countValidate ? null : AppLocalizations.of(context)!.limit_entries_hint,
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
                                  if (v!.trim().isEmpty) {
                                    return null;
                                  }
                                  return Common.isNumeric(v) ? null :  AppLocalizations.of(context)!.limit_entries_hint;
                                }),
                            TextFormField(
                                autofocus: true,
                                controller: _accessController,
                                decoration: InputDecoration(
                                    labelText:  AppLocalizations.of(context)!.access_control,
                                    icon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.help),
                                        onPressed: () {
                                          Common.launchInBrowser(
                                              "https://docs.rsshub.app/install/#pei-zhi-fang-wen-kong-zhi-pei-zhi");
                                        }))),
                            DropdownButtonFormField(
                              isExpanded: true,
                              decoration: InputDecoration(
                                icon: Icon(Icons.language),
                              ),
                              hint: Text( AppLocalizations.of(context)!.csAts),
                              value: _selectLanguage,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectLanguage = value!;
                                });
                              },
                              items:[
                                DropdownMenuItem(child: Text(AppLocalizations.of(context)!.s2t, overflow: TextOverflow.ellipsis), value: 's2t'),
                                DropdownMenuItem(child: Text(AppLocalizations.of(context)!.t2s, overflow: TextOverflow.ellipsis), value: 't2s'),
                              ],
                            ),
                            DropdownButtonFormField<RssFormat>(
                              decoration: InputDecoration(
                                icon: Icon(Icons.rss_feed),
                              ),
                              hint: Text(AppLocalizations.of(context)!.output_format),
                              value: _selectRssFormat,
                              onChanged: (RssFormat? value) {
                                setState(() {
                                  _selectRssFormat = value!;
                                });
                              },
                              items: rssFormats.map((RssFormat rssFormat) {
                                return DropdownMenuItem<RssFormat>(
                                  value: rssFormat,
                                  child: Text(rssFormat.name!),
                                );
                              }).toList(),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _onlyOnce,
                                    onChanged: (value) {
                                      setState(() => _onlyOnce = value!);
                                    },
                                  ),
                                  Text(AppLocalizations.of(context)!.rule_only_once)
                                ]),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.save,
                                  ),
                                  onPressed: _saveConfig,
                                  label: Text(
                                    AppLocalizations.of(context)!.sure,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.delete,
                                  ),
                                  onPressed: () async {
                                    await prefs.clear();
                                    showToastWidget(Text(AppLocalizations.of(context)!.reset_config_hint));
                                  },
                                  label: Text(
                                    AppLocalizations.of(context)!.reset,
                                  ),
                                ),
                              ],
                            )
                          ]))))),
    );
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      await _parseConfig();
      showToastWidget(Text(AppLocalizations.of(context)!.save_config_hint));
    }
  }

  _parseConfig() async {
    RadarConfig radarConfig = new RadarConfig();
    var params = "?";
    // 输出格式
    if (_selectRssFormat != null) {
      params += _selectRssFormat!.value!;
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
      params += "opencc=$_selectLanguage&";
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
      prefs.currentParams = params;
    } else {
      prefs.defaultParams = params;
      prefs.config = json.encode(radarConfig.toJson());
    }
  }

  _loadConfig() async {
    _selectRssFormat = rssFormats.first;
    if (prefs.config.isEmpty) {
      return;
    }
    String configStr = prefs.config;
    RadarConfig radarConfig = RadarConfig.fromJson(json.decode(configStr));
    setState(() {
      // 其他
      _selectLanguage = radarConfig.opencc!;
      // ignore: unnecessary_null_comparison
      _caseSensitive = (radarConfig.filterCaseSensitive != null
          ? radarConfig.filterCaseSensitive
          : false)!;
      // ignore: unnecessary_null_comparison
      _mode = (radarConfig.mode != null ? radarConfig.mode : false)!;
      // ignore: unnecessary_null_comparison
      _outScihub = (radarConfig.scihub != null ? radarConfig.scihub : false)!;
      _countController.text = radarConfig.limit!;
      _accessController.text = radarConfig.access!;

      // 匹配
      _filterController.text = radarConfig.filter!;
      _filterAuthorController.text = radarConfig.filterAuthor!;
      _filterDescriptionController.text = radarConfig.filterDescription!;
      _filterTitleController.text = radarConfig.filterTitle!;
      _filterTimeController.text = radarConfig.filterTime!;

      // 过滤
      _filterOutController.text = radarConfig.filterOut!;
      _filterTitleOutController.text = radarConfig.filterOutTitle!;
      _filterDescriptionOutController.text = radarConfig.filterOutDescription!;
      _filterAuthorOutController.text = radarConfig.filterOutAuthor!;
    });
  }
}
