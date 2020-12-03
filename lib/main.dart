import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
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
  String _currentUrl = "";
  Future<List<Radar>> _radarList = [];
  bool _configVisible = false;

  void initState() {
    super.initState();
  }

  Future<void> _detectUrlByClipboard() async {
    FlutterClipboard.paste().then((value) async {
      if (value.trim().length > 0) {
        setState(() {
          _radarList = _detectUrl(value);
        });
      }
    });
  }

  Future<List<Radar>> _detectUrl(String url) async {
    return await RssHub.detecting(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 60, left: 18),
            child: Align(
              alignment: Alignment.topLeft,
              child:
                  Text("RSSBud", style: Theme.of(context).textTheme.headline6),
            ),
          ),
          _buildCustomLinkPreview(context),
          OutlineButton.icon(
              icon: Icon(Icons.copy_outlined),
              label: Text("从剪贴板读取"),
              borderSide: BorderSide(
                color: Colors.orange,
                style: BorderStyle.solid,
                width: 1,
              ),
              onPressed: _detectUrlByClipboard),
          _createRadarList(context),
          // Visibility(
          //   visible: _configVisible,
          //   child: ,
          // )
        ],
      ),
    ));
  }

  Widget _buildCustomLinkPreview(BuildContext context) {
    if (_currentUrl.trim().length != 0) {
      return FlutterLinkPreview(
        url: _currentUrl.trim(),
        titleStyle: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return null;
  }

  Widget _createRadarList(BuildContext context) {
    return FutureBuilder(
      future: _radarList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Radar> radarList = snapshot.data;
          return ListView.builder(
            itemCount: radarList.length,
            itemBuilder: (context, index) => _buildRssWidget(radarList[index]),
          );
        }
        return null;
      },
    );
  }

  Widget _buildRssWidget(Radar radar) {
    return ListTile(
      title: Text("This is my ListTile"),
      trailing: Wrap(
        spacing: 12, // space between two icons
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
