import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rssaid/common/common.dart';


class NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/imgs/404.png'),
        Text(
          AppLocalizations.of(context)!.notfound,
          style: TextStyle(fontSize: 24,
          fontWeight: FontWeight.bold),
        ),
        Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 8),
            child: ElevatedButton.icon(
                icon: Icon(Icons.support),
                label: Text(
                    AppLocalizations.of(context)!.whichSupport),
                onPressed: () async {
                  await Common.launchInBrowser(
                      'https://docs.rsshub.app/joinus/#ti-jiao-xin-de-rsshub-gui-ze');
                })),
        Padding(
            padding: EdgeInsets.only(left: 24, right: 24),
            child: ElevatedButton.icon(
                icon: Icon(Icons.cloud_upload),
                label: Text(
                    AppLocalizations.of(context)!.submitNewRules),
                onPressed: () async {
                  await Common.launchInBrowser(
                      'https://docs.rsshub.app/social-media.html#_755');
                })),
      ],
    );
  }

}