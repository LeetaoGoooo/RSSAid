import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rssaid/common/common.dart';

class RulesDialog extends StatefulWidget {
  @override
  _RulesDialog createState() => _RulesDialog();
}

class _RulesDialog extends State<RulesDialog> {
  String _rules = "";
  String _ruleSource =
      "https://raw.githubusercontent.com/Cay-Zhang/RSSBudRules/main/rules/radar-rules.js";
  TextEditingController _ruleSourcecontroller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _ruleSourcecontroller.text = _ruleSource;
    Common.getRules().then((value) {
      setState(() {
        _rules = value ?? "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Rules",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                _showDialog(context);
              },
            )
          ],
        ),
        body: SingleChildScrollView(child: Container(child: Text(_rules))),
        floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context)!.refreshRules,
          child: Icon(Icons.refresh),
          onPressed: () {
            _refreshRules(context);
            Future.delayed(Duration(seconds: 3), () {
              Navigator.pop(context);
            });
          },
        ));
  }

  _refreshRules(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7),
              child: Text(AppLocalizations.of(context)!.loading_hint)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
                    controller: _ruleSourcecontroller,
                    decoration: new InputDecoration(labelText: 'Host'),
                  ),
                ),
                actions: <Widget>[
                  new TextButton(
                      child: Text(AppLocalizations.of(context)!.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  new TextButton(
                      child: Text(AppLocalizations.of(context)!.sure),
                      onPressed: () async {
                        if (_ruleSourcecontroller.text.isNotEmpty) {
                          bool result = await Common.setRuleSource(
                              _ruleSourcecontroller.text.trim());
                          if (result) {
                            showToastWidget(Text(AppLocalizations.of(context)!.save_config_hint),);
                          }
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
