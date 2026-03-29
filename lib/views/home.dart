import 'dart:async';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkify/linkify.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rssaid/common/common.dart';
import 'package:rssaid/common/link_helper.dart';
import 'package:rssaid/models/radar.dart';
import 'package:rssaid/radar/rss_plus.dart';
import 'package:rssaid/radar/rsshub.dart';
import 'package:rssaid/radar/rule_type/page_info.dart';
import 'package:rssaid/radar/urlUtils.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:rssaid/views/components/not_found.dart';
import 'package:rssaid/views/config.dart';
import 'package:rssaid/views/settings.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rssaid/l10n/app_localizations.dart';

import 'components/radar_cards.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SharedPrefs prefs = SharedPrefs();
  final RssHub rssHub = RssHub();

  String _currentUrl = '';
  Future<List<Radar>>? _radarList;

  /// Tri-state: null = idle, true = loading, false = done.
  bool? _isLoading;
  bool _configVisible = false;
  bool _notUrlDetected = false;
  bool _isRefreshing = false;

  late StreamSubscription _intentDataStreamSubscription;
  final TextEditingController _inputUrlController = TextEditingController();

  // history is kept as a state variable to avoid stale-local-copy issues.
  late List<String> _history;

  @override
  void initState() {
    super.initState();
    _history = prefs.historyList;

    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .where((event) => event.isNotEmpty)
        .listen(_detectUrlFromShare, onError: (_) {});

    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((value) => _detectUrlFromShare(value));
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _inputUrlController.dispose();
    super.dispose();
  }

  Future<void> _detectUrlFromShare(List<SharedMediaFile> mediaFiles) async {
    if (mediaFiles.isEmpty) return;
    if (![SharedMediaType.url, SharedMediaType.text]
        .contains(mediaFiles.first.type)) return;

    final String text = mediaFiles.first.path;

    setState(() {
      _currentUrl = '';
      _configVisible = false;
      _notUrlDetected = false;
      _isLoading = null;
    });

    final links = linkify(
      text.trim(),
      options: const LinkifyOptions(humanize: false),
      linkifiers: const [UrlLinkifier()],
    ).where((element) => element is LinkableElement);

    if (links.isNotEmpty) {
      _callRadar(links.first.text);
    } else {
      if (mounted) {
        showToastWidget(Text(AppLocalizations.of(context)!.notfoundinshare));
      }
    }
  }

  Future<void> _detectUrlByClipboard() async {
    setState(() {
      _currentUrl = '';
      _configVisible = false;
      _notUrlDetected = false;
      _isLoading = null;
    });
    final ClipboardData? data =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      final link = LinkHelper.verifyLink(data.text);
      if (link != null && link.isNotEmpty) {
        _callRadar(link);
      } else {
        if (mounted) showToast(AppLocalizations.of(context)!.notfoundinClipboard);
      }
    } else {
      if (mounted) showToast(AppLocalizations.of(context)!.notfoundinClipboard);
    }
  }

  void _callRadar(String url) {
    // Single setState to start the loading state — no intermediate rebuilds.
    setState(() {
      _currentUrl = url;
      _configVisible = false;
      _notUrlDetected = false;
      _isLoading = true;
    });

    prefs.record = url;

    _radarList = _detectUrl(url);
    _radarList!.then((value) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (value.isNotEmpty) {
          _configVisible = true;
          _notUrlDetected = false;
        } else {
          _notUrlDetected = true;
        }
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _notUrlDetected = true;
      });
    });
  }

  Future<List<Radar>> _detectUrl(String url) async {
    // Uses the in-memory cached parsed rules — no re-deserialization.
    final Map<String, dynamic>? rules = await Common.getParsedRules();
    if (rules == null || rules.isEmpty) {
      if (mounted) showToast(AppLocalizations.of(context)!.loadRulesFailed);
      return [];
    }
    final String pcUrl = await UrlUtils.getPcWebSiteUrl(url);
    final List<Radar> radarList =
        await rssHub.getPageRSSHub(PageInfo(url: pcUrl, rules: rules));
    final radars = [...radarList, ...await RssPlus.detecting(url)];
    return radars.toSet().toList();
  }

  Future<void> _refreshRules() async {
    setState(() => _isRefreshing = true);
    try {
      await Common.refreshRules();
      if (mounted) showToast(AppLocalizations.of(context)!.refreshRulesSuccess);
    } catch (_) {
      if (mounted) showToast(AppLocalizations.of(context)!.refreshRulesFailed);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('RSSAid', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.network_check),
                  onPressed: _refreshRules,
                ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.inputLinkChecked,
                  ),
                  controller: _inputUrlController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: submitInputUrl,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy_outlined),
                  label: Text(AppLocalizations.of(context)!.fromClipboard),
                  onPressed: _detectUrlByClipboard,
                ),
              ),
              _buildCustomLinkPreview(context),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                child: _createRadarList(context),
              ),
              if (_currentUrl.isEmpty) _historyList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _configVisible
          ? FloatingActionButton(
              tooltip: AppLocalizations.of(context)!.addConfig,
              child: const Icon(Icons.post_add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<Null>(
                    builder: (BuildContext context) => ConfigDialog(),
                    fullscreenDialog: true,
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _trailingWidget() {
    if (_isLoading == true) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.close),
      onPressed: () {
        setState(() {
          _currentUrl = '';
          _configVisible = false;
          _notUrlDetected = false;
          _radarList = null;
          _isLoading = null;
        });
      },
    );
  }

  Widget _buildCustomLinkPreview(BuildContext context) {
    if (_currentUrl.trim().isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Column(
          children: [
            Card(
              child: ListTile(
                dense: true,
                title: Text(
                  _currentUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _trailingWidget(),
              ),
            ),
            const SizedBox(height: 8),
            AnyLinkPreview(
              link: _currentUrl.trim(),
              displayDirection: UIDirection.uiDirectionHorizontal,
              cache: const Duration(hours: 1),
              errorWidget: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createRadarList(BuildContext context) {
    return FutureBuilder<List<Radar>>(
      future: _radarList,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          final radarList = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RSS List',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: radarList.length,
                itemBuilder: (context, index) =>
                    RadarCards(radar: radarList[index]),
              ),
            ],
          );
        }
        if (_notUrlDetected) return NotFound();
        return const SizedBox.shrink();
      },
    );
  }

  /// History list uses [_history] (a state variable) to prevent
  /// index-out-of-range errors after swipe-to-dismiss.
  Widget _historyList() {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _history.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(_history[index]),
              onDismissed: (_) {
                setState(() => _history.removeAt(index));
                prefs.historyList = _history;
              },
              child: Card(
                margin:
                    const EdgeInsets.only(left: 24, right: 24, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                elevation: 0,
                child: InkWell(
                  onTap: () => _callRadar(_history[index]),
                  borderRadius: BorderRadius.circular(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _history[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.clear_all_outlined),
            label: Text(AppLocalizations.of(context)!.clear),
            onPressed: () {
              setState(() => _history = []);
              prefs.historyList = [];
            },
          ),
        ),
      ],
    );
  }

  void submitInputUrl() {
    final url = _inputUrlController.text.trim();
    if (url.isNotEmpty) {
      final link = LinkHelper.verifyLink(url);
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
