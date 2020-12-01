import 'package:rssbud/models/radar.dart';
import 'package:rssbud/models/radar_config.dart';
import 'package:meta/meta.dart';

@immutable
class RadarState {
  final bool isError;
  final bool isLoading;
  final List<Radar> radars;
  final RadarConfig config;

  RadarState({this.isError, this.isLoading, this.radars, this.config});

  factory RadarState.initial() => RadarState(
      isError: false, isLoading: false, radars: const [], config: null);

  RadarState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Radar> radars,
      @required RadarConfig config}) {
    return RadarState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        radars: radars ?? this.radars,
        config: config ?? this.config);
  }
}
