import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rssaid/common/link_helper.dart';
import 'package:rssaid/models/radar.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RadarCard extends StatelessWidget {
  final Radar radar;
  final SharedPrefs prefs;

  const RadarCard({Key? key, required this.radar, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 0,
        child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(radar.title!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left),
                SizedBox(height: 12,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.copy),
                          label: Text(AppLocalizations.of(context)!.copy,),
                          onPressed: () async {
                            var url = await LinkHelper.getSubscriptionUrl(radar);
                            try {
                              Clipboard.setData(ClipboardData(text: url));
                            } catch (e) {
                              showToastWidget( Text(
                                    '${AppLocalizations.of(context)!.copyFailed}: ${e.toString()}',
                                  ));
                              return;
                            }
                            await prefs.removeIfExist("currentParams");
                            showToastWidget(Text(
                                  AppLocalizations.of(context)!.copySuccess,
                                ));
                          },
                        )),
                    Padding(padding: EdgeInsets.only(left: 6, right: 6)),
                    Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.shortcut),
                          label: Text(AppLocalizations.of(context)!.subscribe),
                          onPressed: () async {
                            var url = await LinkHelper.getSubscriptionUrl(radar);
                            Share.share('$url', subject: '${radar.title}');
                          },
                        )),
                  ],
                )
              ],
            )));
  }
}