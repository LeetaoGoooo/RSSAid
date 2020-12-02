
import 'package:meta/meta.dart';

import 'radar_state.dart';


@immutable
class SetRadarStateAction {
  final RadarState radarState;

  SetRadarStateAction(this.radarState);
}


// Future<void> fetchRadarAction(Store<AppState> store) async {

// }