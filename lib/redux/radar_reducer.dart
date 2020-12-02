import 'package:rssbud/redux/radar_action.dart';

import 'radar_state.dart';

radarReducer(RadarState radarState, SetRadarStateAction action) {
  final payload = action.radarState;
  return radarState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      radars: payload.radars,
      config: payload.config);
}
