import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/radar.dart';
import 'package:rssaid/views/config.dart';
import 'package:rssaid/views/settings.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/common.dart';

void main() {
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

  void initState() {
    super.initState();
    _fetchRules();
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
  }

  Future<void> _fetchRules() async {
    await RssHub.fetchRules();
  }

  Future<void> _detectUrlByClipboard() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text.startsWith("http")) {
      setState(() {
        _radarList = _detectUrl(data.text.trim());
        _radarList.then((value) {
          if (value.length > 0) {
            setState(() {
              _configVisible = true;
              _currentUrl = data.text.trim();
              _notUrlDetected = false;
            });
          } else {
            setState(() {
              _notUrlDetected = true;
            });
          }
        });
      });
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('这个世界那么空,你的剪贴板也很空')));
      setState(() {
        _notUrlDetected = false;
      });
    }
  }

  Future<List<Radar>> _detectUrl(String url) async {
    return await RssHub.detecting(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            child: Container(
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  _createRadarList(context)
                ],
              ),
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
              child: FlutterLinkPreview(
                key: ValueKey(_currentUrl),
                url: _currentUrl.trim(),
                titleStyle: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              )));
    }
    return Container();
  }

  Widget _createRadarList(BuildContext context) {
    return FutureBuilder(
      future: _radarList,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.length > 0) {
          List<Radar> radarList = snapshot.data;
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
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
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
                        var host = "https://rsshub.app/";
                        if (prefs.containsKey("RSSHUB")) {
                          host = prefs.getString("RSSHUB");
                        }
                        var url = "$host${radar.path}";
                        if (prefs.containsKey("currentParams")) {
                          url += prefs.getString("currentParams");
                        } else {
                          url += prefs.containsKey("defaultParams")
                              ? prefs.getString("defaultParams")
                              : "";
                        }
                        Clipboard.setData(ClipboardData(text: url));
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
                        final SharedPreferences prefs = await _prefs;
                        var host = "https://rsshub.app/";
                        if (prefs.containsKey("RSSHUB")) {
                          host = prefs.getString("RSSHUB");
                        }
                        Share.share('$host${radar.path}',
                            subject: '${radar.title}');
                      },
                    )),
                  ],
                )
              ],
            )));
  }
}
