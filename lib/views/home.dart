import 'dart:async';
import 'dart:convert';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linkify/linkify.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rssaid/common/common.dart';
import 'package:rssaid/common/link_helper.dart';
import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/radar.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:rssaid/views/components/not_found.dart';
import 'package:rssaid/views/components/radar_card.dart';
import 'package:rssaid/views/config.dart';
import 'package:rssaid/views/settings.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SharedPrefs prefs = SharedPrefs();
  String _currentUrl = "";
  Future<List<Radar>>? _radarList;
  bool _configVisible = false;
  bool _notUrlDetected = false;
  late StreamSubscription _intentDataStreamSubscription;
  TextEditingController _inputUrlController = new TextEditingController();
  late HeadlessInAppWebView headlessWebView;
  late InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();
    // _fetchRules();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .where((event) => event.isNotEmpty)
        .listen(_detectUrlFromShare, onError: (err) {});

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) => {
          {_detectUrlFromShare(value)}
        });

    headlessWebView = new HeadlessInAppWebView(
        onConsoleMessage: (controller, consoleMessage) {
      print("CONSOLE MESSAGE: " + consoleMessage.message);
    }, onWebViewCreated: (controller) {
      webViewController = controller;
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
    headlessWebView.dispose();
  }

  Future<void> _detectUrlFromShare(List<SharedMediaFile> mediaFiles) async {
    if (mediaFiles.isEmpty) {
      return;
    }

    if (mediaFiles.first.type != SharedMediaType.url) {
      return;
    }

    String text = mediaFiles.first.path;

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
      print(_radarList);
      setState(() => _currentUrl = links.first.text);
      _radarList!.then((value) {
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
      showToastWidget(Text(AppLocalizations.of(context)!.notfoundinshare));
    }
  }

  Future<void> _detectUrlByClipboard() async {
    setState(() {
      _currentUrl = '';
      _configVisible = false;
      _notUrlDetected = false;
    });
    ClipboardData? data = (await Clipboard.getData(Clipboard.kTextPlain));
    if (data != null && data.text != null) {
      var link = LinkHelper.verifyLink(data.text);
      if (link != null && link.isNotEmpty) {
        _callRadar(link);
      } else {
        showToast(AppLocalizations.of(context)!.notfoundinClipboard);
      }
    } else {
      showToast(AppLocalizations.of(context)!.notfoundinClipboard);
    }
  }

  void _callRadar(String url) {
    _radarList = _detectUrl(url);
    setState(() => _currentUrl = url);
    prefs.record = url;
    _radarList!.then(
      (value) {
        if (value.length > 0) {
          print("_radarList length > 0, set _configVisible is true");
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
    await headlessWebView.run();
    await webViewController.loadUrl(
        urlRequest: URLRequest(url: WebUri(url), method: 'GET'));
    // await headlessWebView.webViewController.injectJavascriptFileFromAsset(
    //     assetFilePath: 'assets/js/radar-rules.js');
    await headlessWebView.webViewController
        ?.injectJavascriptFileFromAsset(assetFilePath: 'assets/js/url.min.js');
    await headlessWebView.webViewController
        ?.injectJavascriptFileFromAsset(assetFilePath: 'assets/js/psl.min.js');
    await headlessWebView.webViewController?.injectJavascriptFileFromAsset(
        assetFilePath: 'assets/js/route-recognizer.min.js');
    await headlessWebView.webViewController
        ?.injectJavascriptFileFromAsset(assetFilePath: 'assets/js/utils.js');
    String? rules = await Common.getRules();
    if (rules == null || rules.isEmpty) {
      showToast(AppLocalizations.of(context)!.loadRulesFailed);
      return [];
    }
    await headlessWebView.webViewController
        ?.evaluateJavascript(source: 'var rules=$rules');
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
    var res = await headlessWebView.webViewController
        ?.evaluateJavascript(source: expression);
    var radarList = [];
    if (res != null) {
      radarList = Radar.listFromJson(json.decode(res));
    }

    return [...radarList, ...await RssPlus.detecting(url)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("RSSAid", style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new SettingPage()));
              })
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding:
                    EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.inputLinkChecked,
                  ),
                  controller: _inputUrlController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: submitInputUrl,
                )),
            Padding(
                padding:
                    EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                child: ElevatedButton.icon(
                    icon: Icon(Icons.copy_outlined),
                    label: Text(AppLocalizations.of(context)!.fromClipboard),
                    onPressed: _detectUrlByClipboard)),
            _buildCustomLinkPreview(context),
            _createRadarList(context),
            if (_currentUrl == '') _historyList()
          ],
        )),
      ),
      floatingActionButton: _configVisible
          ? FloatingActionButton(
              tooltip: AppLocalizations.of(context)!.addConfig,
              child: Icon(Icons.post_add),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new ConfigDialog();
                    },
                    fullscreenDialog: true));
              },
            )
          : null,
    );
  }

  Widget trailingWidget() {
    if (!(_configVisible || _notUrlDetected)) {
      return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2));
    }
    return IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.close),
        onPressed: () {
          setState(() {
            _currentUrl = "";
            _configVisible = false;
            _notUrlDetected = false;
            _radarList = null;
          });
        });
  }

  Widget _buildCustomLinkPreview(BuildContext context) {
    if (_currentUrl.trim().length != 0) {
      return Card(
          margin: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
          elevation: 0,
          child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      dense: true,
                      title: Text(_currentUrl,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: trailingWidget(),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  AnyLinkPreview(
                    link: _currentUrl.trim(),
                    displayDirection: UIDirection.uiDirectionHorizontal,
                    cache: Duration(hours: 1),
                    errorWidget: Container(
                      child: Text('Oops!'),
                    ),
                  ),
                ],
              )));
    }
    return SizedBox.shrink();
  }

  Widget _createRadarList(BuildContext context) {
    return FutureBuilder(
      future: _radarList,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            (snapshot.data as List).length > 0) {
          List<Radar> radarList = snapshot.data as List<Radar>;
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: radarList.length,
            itemBuilder: (context, index) => RadarCard(
              radar: radarList[index],
              prefs: prefs,
            ),
          );
        }
        return _notUrlDetected
            ? NotFound()
            : Container();
      },
    );
  }

  ///History recoeds list widget
  Widget _historyList() {
    var history = prefs.historyList;
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
                prefs.historyList = history;
                if (mounted) setState(() {});
              },
              child: Card(
                  margin: EdgeInsets.only(left: 24, right: 24, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  elevation: 0,
                  child: InkWell(
                    onTap: () => _callRadar(history[index]),
                    borderRadius: BorderRadius.circular(10.0),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(history[index],
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  )),
            );
          },
        ),
        Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 8),
            child: ElevatedButton.icon(
                icon: Icon(Icons.clear_all_outlined),
                label: Text(AppLocalizations.of(context)!.clear),
                onPressed: () {
                  prefs.historyList = [];
                })),
      ],
    );
  }

  void submitInputUrl() {
    var url = _inputUrlController.text.trim();
    if (url.length > 0) {
      var link = LinkHelper.verifyLink(url);
      if (link != null) {
        _callRadar(link);
        return;
      } else {
        showToast(AppLocalizations.of(context)!.linkError);
      }
    } else {
      showToast(AppLocalizations.of(context)!.notfound);
    }
  }
}
