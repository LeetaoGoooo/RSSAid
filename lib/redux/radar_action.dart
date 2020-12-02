import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:rssbud/models/radar.dart';
import 'package:rssbud/radar/radar.dart';
import 'package:rssbud/redux/store.dart';

import 'radar_state.dart';

@immutable
class SetRadarStateAction {
  final RadarState radarState;

  SetRadarStateAction(this.radarState);
}

@immutable
class DetectRadarStateAction {
  final DetectRadarState detectRadarState;

  DetectRadarStateAction(this.detectRadarState);
}

Future<void> detectRadarAction(Store<AppState> store, String url) async {
  store.dispatch(DetectRadarStateAction(DetectRadarState(isLoading: true)));

  try {
    final res = await RssHub.detecting(url);
    final jsonData = json.decode(res);
    store.dispatch(DetectRadarStateAction(DetectRadarState(
        isError: false, isLoading: false, radar: Radar.fromJson(jsonData))));
  } catch (error) {
    store.dispatch(DetectRadarStateAction(
        DetectRadarState(isError: true, isLoading: false)));
  }
}

Future<void> fetchRadarsAction(Store<AppState> store) async {
  store.dispatch(SetRadarStateAction(RadarState(isLoading: true)));

  try {
    await RssHub.fetchRules();
    store.dispatch(
        SetRadarStateAction(RadarState(isError: false, isLoading: false)));
  } catch (error) {
    store.dispatch(
        SetRadarStateAction(RadarState(isError: true, isLoading: false)));
  }
}
