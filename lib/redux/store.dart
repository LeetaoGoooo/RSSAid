import 'package:meta/meta.dart';

import 'radar_state.dart';

@immutable
class AppState {
  final String url;
  final RadarState radarState;

  AppState({
    @required this.radarState,
    @required this.url
  });

  AppState copyWith({
    RadarState radarState,
    String url,
  }) {
    return AppState(
      radarState: radarState ?? this.radarState,
       url: url ?? this.url
    );
  }
}

AppState appReducer(AppState state,dynamic action) {

}