import 'package:rssbud/models/radar.dart';
import 'package:meta/meta.dart';

@immutable
class RadarState {
  final bool isError;
  final bool isLoading;
  // final List<Radar> radars;

  RadarState({
    this.isError,
    this.isLoading,
    // this.radars
  });

  factory RadarState.initial() => RadarState(isError: false, isLoading: false
      // , radars: const []
      );

  RadarState copyWith({
    @required bool isError,
    @required bool isLoading,
    // @required List<Radar> radars
  }) {
    return RadarState(
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      // radars: radars ?? this.radars
    );
  }
}

@immutable
class DetectRadarState {
  final bool isError;
  final bool isLoading;
  final Radar radar;

  DetectRadarState({this.isError, this.isLoading, this.radar});

  factory DetectRadarState.initial() =>
      DetectRadarState(isError: false, isLoading: false, radar: null);

  DetectRadarState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required Radar radar}) {
    return DetectRadarState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        radar: radar ?? this.radar);
  }
}
