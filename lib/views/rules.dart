import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rssaid/common/common.dart';

class RulesDialog extends StatefulWidget {
  @override
  _RulesDialog createState() => _RulesDialog();
}

class _RulesDialog extends State<RulesDialog> {
  String _rules = "";

  @override
  void initState() {
    super.initState();
    refreshRules();
  }

  Future<void> refreshRules() async {
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
          )
        ),
        body: SingleChildScrollView(child: Container(child: Text(_rules))),
        floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context)!.refreshRules,
          child: Icon(Icons.refresh),
          onPressed: () async {
            await refreshRules();
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
}
