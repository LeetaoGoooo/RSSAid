import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:rssbud/redux/radar_action.dart';
import 'package:rssbud/redux/radar_reducer.dart';

import 'radar_state.dart';

@immutable
class AppState {
  final RadarState radarState;

  AppState({@required this.radarState});

  AppState copyWith({
    RadarState radarState,
  }) {
    return AppState(radarState: radarState ?? this.radarState);
  }
}

AppState appReducer(dynamic state, dynamic action) {
  if (action is SetRadarStateAction) {
    final nextRadarState = radarRulesReducer(state.radarState, action);
    return state.copyWith(radarState: nextRadarState);
  } else if (action is DetectRadarStateAction) {
    final nextRadarState = radarDetectReducer(state.radarState, action);
    return state.copyWith(radarState: nextRadarState);
  }
  return state;
}

class Redux {
  static Store<AppState> _store;

  static Store<AppState> get store {
    if (_store == null) {
      throw Exception("store is not initialized");
    }
    return _store;
  }

  static Future<void> init() async {
    final radarStateInitial = RadarState.initial();
    _store = Store<AppState>(appReducer,
        middleware: [thunkMiddleware],
        initialState: AppState(radarState: radarStateInitial));
  }
}
