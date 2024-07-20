import 'package:flutter/material.dart';
import 'package:rssaid/models/radar.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rssaid/common/link_helper.dart';
import 'package:rssaid/shared_prefs.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum RadarCardAction { copy, subscribe, preview, doc }
class RadarCards extends StatelessWidget {
  final Radar radar;
  const RadarCards({Key? key, required this.radar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Card(
        child: ListTile(
          dense: true,
        title: Text(radar.title!),
        subtitle: Text(radar.docs!),
          trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem(
                    value: RadarCardAction.copy,
                    child: ListTile(
                      leading: Icon(Icons.copy),
                      title: Text(
                        AppLocalizations.of(context)!.copy,
                      ),
                      onTap: () async {
                        var url =
                        await LinkHelper.getSubscriptionUrl(radar.isRssHub, radar.path!);
                        try {
                          Clipboard.setData(ClipboardData(text: url));
                        } catch (e) {
                          showToastWidget(Text(
                            '${AppLocalizations.of(context)!.copyFailed}: ${e.toString()}',
                          ));
                          return;
                        }
                        final SharedPrefs prefs = SharedPrefs();
                        await prefs.removeIfExist("currentParams");
                        showToastWidget(Text(
                          AppLocalizations.of(context)!.copySuccess,
                        ));
                        Navigator.of(context).pop();
                      },
                    )),
                PopupMenuItem(
                  value: RadarCardAction.subscribe,
                  child: ListTile(
                    leading: Icon(Icons.shortcut),
                    title: Text(AppLocalizations.of(context)!.subscribe),
                    onTap: () async {
                      var url =
                      await LinkHelper.getSubscriptionUrl(radar.isRssHub, radar.path!);
                      Share.share('$url', subject: radar.title);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                // TODO preview
                // PopupMenuItem(
                //   value: RadarCardAction.subscribe,
                //   child: ListTile(
                //     leading: Icon(Icons.preview),
                //     title: Text(AppLocalizations.of(context)!.preview),
                //     onTap: () async {
                //       var url =
                //           await LinkHelper.getSubscriptionUrl(isRssHub, path);
                //     },
                //   ),
                // ),
              ]),
      ),);
  }
}
