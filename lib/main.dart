// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_link_preview/flutter_link_preview.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:linkify/linkify.dart';
import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/radar.dart';
import 'package:rssaid/views/config.dart';
import 'package:rssaid/views/settings.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:share/share.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'common/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(RSSBudApp());

  var systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

class RSSBudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light, //指定亮度主题，有白色/黑色两种可选。
          primaryColor: Colors.orange, //这里我们选蓝色为基准色值。
          accentColor: Colors.orange[100]), //这里我们选浅蓝色为强调色值。
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentUrl = "";
  Future<List<Radar>> _radarList;
  bool _configVisible = false;
  ScrollController _scrollViewController;
  bool _showAppbar = true;
  bool _isScrollingDown = false;
  bool _notUrlDetected = false;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  StreamSubscription _intentDataStreamSubscription;
  TextEditingController _inputUrlController = new TextEditingController();
  HeadlessInAppWebView headlessWebView;
  InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();
    _fetchRules();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream()
        .where((event) => event != null)
        .listen(_detectUrlFromShare, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText()
        .then((value) => {_detectUrlFromShare(value)});

    _scrollViewController = new ScrollController();
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!_isScrollingDown) {
          _isScrollingDown = true;
          _showAppbar = false;
          setState(() {});
        }
      }

      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_isScrollingDown) {
          _isScrollingDown = false;
          _showAppbar = true;
          setState(() {});
        }
      }
    });

    headlessWebView = new HeadlessInAppWebView(
        onConsoleMessage: (controller, consoleMessage) {
      print("CONSOLE MESSAGE: " + consoleMessage.message);
    }, onWebViewCreated: (controller) {
      print("webview created");
      webViewController = controller;
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
    headlessWebView?.dispose();
  }

  Future<void> _fetchRules() async {
    /// 将 rules 加载到 prefres
    await Common.refreshRules();
  }

  Future<void> _detectUrlFromShare(String text) async {
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _currentUrl = '';
      _configVisible = false;
      _notUrlDetected = false;
    });
    var links = linkify(text.trim(),
            options: LinkifyOptions(humanize: false),
            linkifiers: [UrlLinkifier()])
        .where((element) => element is LinkableElement);
    if (links.isNotEmpty) {
      _radarList = _detectUrl(links.first.text);
      setState(() => _currentUrl = links.first.text);
      _radarList.then((value) {
        if (value.length > 0) {
          setState(() {
            _configVisible = true;
            _notUrlDetected = false;
          });
        } else {
          setState(() {
            _notUrlDetected = true;
          });
        }
      });
    } else {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: Text('分享没有发现链接')));
    }
  }

  Future<void> _detectUrlByClipboard() async {
    setState(() {
      _currentUrl = '';
      _configVisible = false;
      _notUrlDetected = false;
    });
    ClipboardData data = (await Clipboard.getData(Clipboard.kTextPlain));
    if (data != null && data.text != null) {
      var link = _verifyLink(data.text);
      if (link != null) {
        _callRadar(link);
      } else {
        _showSnackBar("报告主人，剪贴板没有发现链接");
      }
    } else {
      _showSnackBar("报告主人，剪贴板空空的，我的心也很空");
    }
  }

  /// verify link return link
  /// else return null
  String _verifyLink(String url) {
    var links = linkify(url.trim(),
            options: LinkifyOptions(humanize: false),
            linkifiers: [UrlLinkifier()])
        .where((element) => element is LinkableElement);
    if (links.isEmpty) {
      return null;
    }
    return links.first.text;
  }

  void _callRadar(String url) {
    _radarList = _detectUrl(url);
    setState(() => _currentUrl = url);
    _addRecord(url);
    _radarList.then(
      (value) {
        if (value.length > 0) {
          setState(() {
            _configVisible = true;
            _notUrlDetected = false;
          });
        } else {
          setState(() {
            _notUrlDetected = true;
          });
        }
      },
    );
  }

  Future<List<Radar>> _detectUrl(String url) async {
    final SharedPreferences prefs = await _prefs;
  
    await headlessWebView?.run();
    await webViewController
        .loadUrl(urlRequest: URLRequest(url: Uri.parse(url), method: 'GET'));
    // await headlessWebView?.webViewController.injectJavascriptFileFromAsset(
    //     assetFilePath: 'assets/js/radar-rules-ios.js');
    await headlessWebView.webViewController.evaluateJavascript(source: 'var rules=${prefs.getString("Rules")}');
    await headlessWebView.webViewController
        .injectJavascriptFileFromAsset(assetFilePath: 'assets/js/url.min.js');
    await headlessWebView.webViewController
        .injectJavascriptFileFromAsset(assetFilePath: 'assets/js/psl.min.js');
    await headlessWebView.webViewController.injectJavascriptFileFromAsset(
        assetFilePath: 'assets/js/route-recognizer.min.js');
    await headlessWebView.webViewController
        .injectJavascriptFileFromAsset(assetFilePath: 'assets/js/utils.js');
    var html = await webViewController.getHtml();
    var uri = Uri.parse(url);
    String expression = """
      getPageRSSHub({
                            url: "$url",
                            host: "${uri.host}",
                            path: "${uri.path}",
                            html: `$html`,
                            rules: rules
                        });
      """;
    var res = await headlessWebView?.webViewController
        .evaluateJavascript(source: expression);
    var radarList = Radar.listFromJson(json.decode(res));

    return [...radarList,...await RssPlus.detecting(url)];
  }

  /// Get history records
  Future<List<String>> _getHistoryList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('historyListKey') ?? [];
  }

  /// Add new record at the top of the list
  Future<void> _addRecord(String url) async {
    final prefs = await SharedPreferences.getInstance();
    var historyList = prefs.getStringList('historyListKey') ?? [];
    historyList.remove(url);
    historyList.insert(0, url);
    await prefs.setStringList('historyListKey', historyList);
  }

  /// Save history records after user delete one
  Future<void> _setRecord(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('historyListKey', history);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: _showAppbar
          ? AppBar(
              backgroundColor: Colors.white,
              centerTitle: false,
              title:
                  Text("RSSAid", style: Theme.of(context).textTheme.headline6),
              actions: [
                IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SettingPage()));
                    })
              ],
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
            controller: _scrollViewController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildCustomLinkPreview(context),
                Padding(
                    padding:
                        EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                    child: FlatButton.icon(
                        minWidth: double.infinity,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Color.fromARGB(255, 242, 242, 247),
                        icon: Icon(Icons.copy_outlined, color: Colors.orange),
                        label: Text("从剪贴板读取",
                            style: TextStyle(color: Colors.orange)),
                        onPressed: _detectUrlByClipboard)),
                Padding(
                    padding:
                        EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 8),
                    child: FlatButton.icon(
                        minWidth: double.infinity,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Color.fromARGB(255, 242, 242, 247),
                        icon: Icon(Icons.input, color: Colors.orange),
                        label: Text("手动输入一下",
                            style: TextStyle(color: Colors.orange)),
                        onPressed: _showInputDialog)),
                _createRadarList(context),
                if (_currentUrl == '') _historyList()
              ],
            )),
      ),
      floatingActionButton: _configVisible
          ? FloatingActionButton(
              tooltip: "添加配置",
              child: Icon(Icons.post_add, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new ConfigDialog();
                    },
                    fullscreenDialog: true));
              },
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }

  Widget _buildCustomLinkPreview(BuildContext context) {
    if (_currentUrl.trim().length != 0) {
      return Card(
          margin: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
          color: Color.fromARGB(255, 242, 242, 247),
          elevation: 0,
          child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_currentUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if (!(_configVisible || _notUrlDetected))
                          SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          IconButton(
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _currentUrl = "";
                                  _configVisible = false;
                                  _notUrlDetected = false;
                                  _radarList = [] as Future<List<Radar>>;
                                });
                              })
                      ],
                    ),
                  ),
                  if (_configVisible)
                    FlutterLinkPreview(
                      key: ValueKey(_currentUrl),
                      url: _currentUrl.trim(),
                      titleStyle: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              )));
    }
    return Container();
  }

  Widget _createRadarList(BuildContext context) {
    return FutureBuilder(
      future: _radarList,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<Radar> radarList = snapshot.data as List<Radar>;
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: radarList.length,
            itemBuilder: (context, index) => _buildRssWidget(radarList[index]),
          );
        }
        return _notUrlDetected
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/imgs/404.png'),
                  Text(
                    "报告主人，真的没有啦o(╥﹏╥)o",
                    style: TextStyle(fontSize: 12),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 24, right: 24, top: 8),
                      child: FlatButton.icon(
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Color.fromARGB(255, 242, 242, 247),
                          icon: Icon(Icons.support, color: Colors.orange),
                          label: Text("看看支持什么规则",
                              style: TextStyle(color: Colors.orange)),
                          onPressed: () async {
                            await Common.launchInBrowser(
                                'https://docs.rsshub.app/joinus/#ti-jiao-xin-de-rsshub-gui-ze');
                          })),
                  Padding(
                      padding: EdgeInsets.only(left: 24, right: 24),
                      child: FlatButton.icon(
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Color.fromARGB(255, 242, 242, 247),
                          icon: Icon(Icons.cloud_upload, color: Colors.orange),
                          label: Text("提交新的规则",
                              style: TextStyle(color: Colors.orange)),
                          onPressed: () async {
                            await Common.launchInBrowser(
                                'https://docs.rsshub.app/social-media.html#_755');
                          })),
                ],
              )
            : Container();
      },
    );
  }

  Widget _buildRssWidget(Radar radar) {
    return Card(
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 16),
        color: Color.fromARGB(255, 242, 242, 247),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 0,
        child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(radar.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: FlatButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.white,
                      icon: Icon(
                        Icons.copy,
                        color: Colors.orange,
                      ),
                      label: Text(
                        "复制",
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () async {
                        final SharedPreferences prefs = await _prefs;
                        var url = await _getSubscriptionUrl(radar);

                        try {
                          Clipboard.setData(ClipboardData(text: url));
                        } catch (e) {
                          HttpClient client = new HttpClient();
                          var request = await client.postUrl(Uri.parse(
                              'https://hook.bearychat.com/=bwHww/incoming/e6f647eebe08ec2add99c8d6cf2c4131'));
                          request.headers.contentType = new ContentType(
                              "application", "json",
                              charset: "utf-8");
                          request.add(utf8.encode(
                              json.encode({"text": "${e.toString()}"})));
                          var response = await request.close();
                          print(response.statusCode);
                        }
                        if (prefs.containsKey("currentParams")) {
                          prefs.remove("currentParams");
                        }
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('复制成功')));
                      },
                    )),
                    Padding(padding: EdgeInsets.only(left: 6, right: 6)),
                    Expanded(
                        child: FlatButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.white,
                      icon: Icon(Icons.done, color: Colors.orange),
                      label: Text("订阅", style: TextStyle(color: Colors.orange)),
                      onPressed: () async {
                        var url = await _getSubscriptionUrl(radar);
                        Share.share('$url', subject: '${radar.title}');
                      },
                    )),
                  ],
                )
              ],
            )));
  }

  ///History recoeds list widget
  Widget _historyList() {
    return FutureBuilder<List<String>>(
        future: _getHistoryList(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            var history = snapshot.data;
            return Column(
              children: [
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: ValueKey(history[index]),
                      onDismissed: (direction) {
                        setState(() => history.removeAt(index));
                        _setRecord(history);
                      },
                      child: Card(
                          margin:
                              EdgeInsets.only(left: 24, right: 24, bottom: 12),
                          color: Color.fromARGB(255, 242, 242, 247),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 0,
                          child: InkWell(
                            onTap: () => _callRadar(history[index]),
                            borderRadius: BorderRadius.circular(10.0),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(history[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.orange)),
                            ),
                          )),
                    );
                  },
                ),
                Padding(
                    padding:
                        EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 8),
                    child: FlatButton.icon(
                        minWidth: double.infinity,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Color.fromARGB(255, 242, 242, 247),
                        icon: Icon(Icons.clear_all_outlined,
                            color: Colors.orange),
                        label: Text("清除所有",
                            style: TextStyle(color: Colors.orange)),
                        onPressed: () {
                          _setRecord([]);
                        })),
              ],
            );
          }
          return Center();
        });
  }

  /// 显示输入地址框
  Future<void> _showInputDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("输入要检测的链接"),
            content: Container(
              child: TextField(
                controller: _inputUrlController,
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    var url = _inputUrlController.text.trim();
                    if (url.length > 0) {
                      var link = _verifyLink(url);
                      if (link != null) {
                        _callRadar(link);
                        return;
                      } else {
                        _showSnackBar("报告主人，链接好像出问题了");
                      }
                    } else {
                      _showSnackBar("报告主人，链接空空的");
                    }
                  },
                  child: Text("确认"))
            ],
          );
        });
  }

  _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Text(text)));
  }

  _getSubscriptionUrl(Radar radar) async {
    final SharedPreferences prefs = await _prefs;
    var host = "https://rsshub.app/";
    if (prefs.containsKey("RSSHUB")) {
      host = prefs.getString("RSSHUB");
    }
    var url = "$host${radar.path}";
    print("isRssHub:${radar.isRssHub}");
    if (radar.isRssHub != null && !radar.isRssHub) {
      url = radar.path;
    }

    if (prefs.containsKey("currentParams")) {
      url += prefs.getString("currentParams");
    } else {
      url += prefs.containsKey("defaultParams")
          ? prefs.getString("defaultParams")
          : "";
    }
    return url;
  }
}
