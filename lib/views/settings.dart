import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rssaid/common/common.dart';
import 'package:rssaid/views/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _domain = "https://rsshub.app";
  PackageInfo packageInfo = PackageInfo(
    appName: 'RSSAid',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey("RSSHUB")) {
      setState(() {
        _domain = prefs.getString("RSSHUB")!;
      });
    }
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  void setDomain(String domain) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _domain = domain;
    });
    prefs.setString("RSSHUB", domain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.settings,
                style: Theme.of(context).textTheme.titleLarge),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: Container(
          margin: EdgeInsets.only(top: 16),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding:  EdgeInsets.only(left: 24, right: 24, bottom: 8),
              child: Text(AppLocalizations.of(context)!.common, style: Theme.of(context).textTheme.titleMedium,),
              ),
              CommonRows(_domain, setDomain),
              Padding(padding:  EdgeInsets.only(left: 24, right: 24, bottom: 8),
                child: Text(AppLocalizations.of(context)!.about, style: Theme.of(context).textTheme.titleMedium,),
              ),
              AboutRows(version: packageInfo.version,)
            ],
          ),
        ));
  }
}

// ignore: must_be_immutable
class CommonRows extends StatelessWidget {
  String? _domain;
  Function? _domainSetCallback;
  TextEditingController _domainController = new TextEditingController();

  CommonRows(String domain, Function domainSetFunc) {
    this._domain = domain;
    this._domainController.text = domain;
    this._domainSetCallback = domainSetFunc;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildHowUseSoftware(context),
        _buildRssHubDomain(context),
        _buildRules(context)
      ],
    );
  }

  Widget _buildRssHubDomain(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.domain),
        title: Text(
          "RSSHub URL",
        ),
        onTap: () {
          _showDialog(context);
        },
      ),
    );
  }

  Widget _buildHowUseSoftware(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.apps),
        title: Text(
          AppLocalizations.of(context)!.user_manual,
        ),
        onTap: () {
          Common.launchInBrowser("https://docs.rsshub.app");
        },
      ),
    );
  }

  Widget _buildRules(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.note),
        title: Text(
          "Rules",
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute<Null>(builder: (_) {
            return new RulesDialog();
          }));
        },
      ),
    );
  }

  _showDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return new AlertDialog(
                // contentPadding: const EdgeInsets.all(16.0),
                content: Container(
                  child: TextField(
                    controller: _domainController,
                    decoration: new InputDecoration(labelText: 'Host'),
                  ),
                ),
                actions: <Widget>[
                   TextButton(
                      child: Text(AppLocalizations.of(context)!.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      child: Text(AppLocalizations.of(context)!.sure),
                      onPressed: () {
                        if (_domainController.text != _domain) {
                          _domainSetCallback!(_domainController.text);
                        }
                        Navigator.pop(context);
                      })
                ],
              );
            },
          );
        });
  }
}

class AboutRows extends StatelessWidget {
  final String version;

  const AboutRows({Key? key, required this.version}) : super(key: key);

  Widget _buildAboutItem(
      String name, IconData icon, String trailing, String url) {
    return Card(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          name,
        ),
        trailing: trailing.isNotEmpty ? Text(trailing) : null,
        onTap: url.isNotEmpty
            ? () async {
                await Common.launchInBrowser(url);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildAboutItem("Version", Icons.info, version, ""),
        _buildAboutItem("Github", Icons.favorite, "",
            "https://github.com/LeetaoGoooo/RSSAid"),
        _buildAboutItem("Author", Icons.person, "", "https://x.com/LeetaoGoooo")
      ],
    );
  }
}
