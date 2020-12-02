import 'package:rssbud/redux/radar_action.dart';

import 'radar_state.dart';

radarRulesReducer(RadarState radarState, SetRadarStateAction action) {
  final payload = action.radarState;
  return radarState.copyWith(
    isError: payload.isError,
    isLoading: payload.isLoading,
    // radars: payload.radars
  );
}

radarDetectReducer(
    DetectRadarState detectRadarState, DetectRadarStateAction action) {
  final payload = action.detectRadarState;
  return detectRadarState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      radar: payload.radar);
}
