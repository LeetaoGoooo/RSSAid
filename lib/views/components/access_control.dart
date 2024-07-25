import 'package:flutter/material.dart';
import 'package:rssaid/shared_prefs.dart';

class AccessControl {
  late ValueNotifier<bool> enable;

  void toggle() {
    enable.value = !enable.value;
  }

  AccessControl({required bool enable}) : enable = ValueNotifier<bool>(enable);
}

class AccessControlWidget extends StatefulWidget {
  @override
  _AccessControlWidgetState createState() => _AccessControlWidgetState();
}

class _AccessControlWidgetState extends State<AccessControlWidget> {
  late AccessControl accessControl;
  final SharedPrefs _sharedPrefs = SharedPrefs();

  @override
  void initState() {
    super.initState();
    accessControl = AccessControl(enable: _sharedPrefs.accessControl);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: ValueListenableBuilder<bool>(
        valueListenable: accessControl.enable,
        builder: (BuildContext context, bool enable, child) {
          return ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.lock),
                title: Text(
                  "Access Control",
                ),
                trailing: Switch(
                  value: enable,
                  onChanged: (_) async {
                    accessControl.toggle();
                    _sharedPrefs.accessControl = accessControl.enable.value;
                    if (!_sharedPrefs.accessControl) {
                      await _sharedPrefs.removeIfExist("accessKey");
                    }
                  },
                ),
              ),
              accessControl.enable.value
                  ? TextFormField(
                      obscureText: true,
                      initialValue: _sharedPrefs.accessKey,
                      obscuringCharacter: "*",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                      decoration: InputDecoration(
                        hintText: "Access Key",
                        icon: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Icon(Icons.key)),
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.visiblePassword,
                      onFieldSubmitted: (value) =>
                          {_sharedPrefs.accessKey = value},
                    )
                  : SizedBox.shrink()
            ],
          );
        },
      ),
    );
  }
}
