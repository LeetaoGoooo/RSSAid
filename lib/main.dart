import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:rssbud/models/radar.dart';
import 'package:rssbud/radar/radar.dart';

void main() {
  runApp(RSSBudApp());
}

class RSSBudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  void initState() {
    super.initState();
  }

  Future<void> _detectUrl() async {
    FlutterClipboard.paste().then((value) async {
      if(value.trim().length > 0) {
        List<Radar> detectRadarList  = await RssHub.detecting(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60,left: 18),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("RSSBud",
                    style: Theme.of(context).textTheme.headline6),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _detectUrl();
        },
        tooltip: 'Copy from clipboard',
        child: Icon(Icons.copy),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
