import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rssaid/common/common.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:rssaid/views/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'components/access_control.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final SharedPrefs prefs = SharedPrefs();

  String _domain = "https://rsshub.app";
  late List<String> _domains;

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

    setState(() {
      _domain = prefs.domain;
      _domains = prefs.domains;
    });

    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  void setDomain(String domain) async {
    setState(() {
      _domain = domain;
    });
    prefs.domain = domain;
  }

  void setDomains(List<String> domains) async {
    setState(() {
      _domains = domains;
    });
    prefs.domains = domains;
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
        body: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding:  EdgeInsets.only(left: 24, right: 24, bottom: 8),
                child: Text(AppLocalizations.of(context)!.common, style: Theme.of(context).textTheme.titleMedium,),
              ),
              CommonRows(
                domain: _domain,
                domains: _domains,
                onDomainSet: (newDomain) {
                  setState(() {
                    _domain = newDomain;
                    prefs.domain = newDomain;
                  });
                },
                onDomainsSet: (newDomains) {
                  setState(() {
                    _domains = newDomains;
                    prefs.domains = newDomains;
                  });
                },
              ),
              Padding(padding:  EdgeInsets.only(left: 24, right: 24, bottom: 8),
                child: Text(AppLocalizations.of(context)!.about, style: Theme.of(context).textTheme.titleMedium,),
              ),
              AboutRows(version: packageInfo.version,)
            ],
          ),),
        );
  }
}

// ignore: must_be_immutable
class CommonRows extends StatefulWidget {
  final String domain;
  final List<String> domains;
  final Function(String) onDomainSet;
  final Function(List<String>) onDomainsSet;

  const CommonRows({
    Key? key,
    required this.domain,
    required this.domains,
    required this.onDomainSet,
    required this.onDomainsSet,
  }) : super(key: key);

  @override
  _CommonRowsState createState() => _CommonRowsState();
}

class _CommonRowsState extends State<CommonRows> {
  late TextEditingController _domainController;
  late List<String> _localDomains;

  @override
  void initState() {
    super.initState();
    _domainController = TextEditingController();
    _localDomains = List.from(widget.domains);
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  void _addDomain(String domain) {
    if (domain.isNotEmpty && !_localDomains.contains(domain.trim())) {
      setState(() {
        _localDomains.add(domain.trim());
        widget.onDomainsSet(_localDomains);
      });
      _domainController.clear();
    }
  }

  void _removeDomain(String domain) {
    if (_localDomains.length > 1) {
      setState(() {
        _localDomains.remove(domain);
        widget.onDomainsSet(_localDomains);

        // If the current domain is removed, select the first available domain
        if (domain == widget.domain) {
          widget.onDomainSet(_localDomains.first);
        }
      });
    }
  }

  Widget _buildDomainCheckboxes() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _localDomains.length,
      itemBuilder: (context, index) {
        final domain = _localDomains[index];
        return Row(
          children: [
            Checkbox(
              value: domain == widget.domain,
              onChanged: (bool? selected) {
                if (selected == true) {
                  widget.onDomainSet(domain);
                }
              },
            ),
            Expanded(child: Text(domain)),
            if (_localDomains.length > 1)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeDomain(domain),
              ),
          ],
        );
      },
    );
  }

  void _showDomainDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _domainController,
                decoration: InputDecoration(
                  labelText: 'Add New Domain',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addDomain(_domainController.text),
                  ),
                ),
                onSubmitted: _addDomain,
              ),
              _buildDomainCheckboxes(),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                // Ensure the current domain is still valid
                if (!_localDomains.contains(widget.domain)) {
                  widget.onDomainSet(_localDomains.first);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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

  Widget _buildRssHubDomain(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      child: ListTile(
        leading: Icon(Icons.domain),
        title: Text("RSSHub URL"),
        subtitle: Text(widget.domain),
        onTap: () => _showDomainDialog(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildHowUseSoftware(context),
        _buildRssHubDomain(context),
        AccessControlWidget(),
        _buildRules(context)
      ],
    );
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
