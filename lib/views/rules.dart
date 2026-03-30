import 'package:flutter/material.dart';
import 'package:rssaid/l10n/app_localizations.dart';
import 'package:rssaid/common/common.dart';

class RulesDialog extends StatefulWidget {
  @override
  _RulesDialog createState() => _RulesDialog();
}

class _RulesDialog extends State<RulesDialog> {
  String _rules = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshRules();
  }

  Future<void> refreshRules({bool force = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    Common.getRules(forceRefresh: force).then((value) {
      if (mounted) {
        setState(() {
          _rules = value ?? "";
          _isLoading = false;
        });
      }
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
            )),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _rules.isEmpty
                ? Center(child: Text("No rules found. Try refreshing."))
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: SelectableText(_rules),
                  ),
        floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context)!.refreshRules,
          child: Icon(Icons.refresh),
          onPressed: () async {
            _refreshRules(context);
            await refreshRules(force: true);
            Navigator.pop(context); // Close the loading dialog
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
