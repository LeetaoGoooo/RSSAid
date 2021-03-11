// @dart=2.9

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RulesDialog extends StatelessWidget {
  String _rules;
  Function _refreshCallback;

  RulesDialog(rules, Function _refreshCallback) {
    this._rules = rules;
    this._refreshCallback = _refreshCallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text("RSSHub Rules"),
        ),
        body: SingleChildScrollView(child: Container(child: Text(_rules))),
        floatingActionButton: FloatingActionButton(
          tooltip: "更新规则",
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
    _refreshCallback();
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7), child: Text("疯狂加载中...")),
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
