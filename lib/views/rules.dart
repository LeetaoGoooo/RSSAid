import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        _rules = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Rules",
            style: Theme.of(context).textTheme.headline6,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                _showDialog(context);
              },
            )
          ],
        ),
        body: SingleChildScrollView(child: Container(child: Text(_rules))),
        floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context)!.refreshRules,
          child: Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            _refreshRules(context);
            Future.delayed(Duration(seconds: 3), () {
              Navigator.pop(context);
            });
          },
          backgroundColor: Colors.orange,
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
                      child: Text(AppLocalizations.of(context)!.cancel,
                          style: TextStyle(color: Colors.orange)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  new TextButton(
                      child: Text(AppLocalizations.of(context)!.sure,
                          style: TextStyle(color: Colors.orange)),
                      onPressed: () async {
                        if (_ruleSourcecontroller.text.isNotEmpty) {
                          bool result = await Common.setRuleSource(
                              _ruleSourcecontroller.text.trim());
                          if (result) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .save_config_hint),
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                            ));
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
