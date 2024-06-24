/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImgsGen {
  const $AssetsImgsGen();

  /// File path: assets/imgs/404.png
  AssetGenImage get a404 => const AssetGenImage('assets/imgs/404.png');

  /// List of all assets
  List<AssetGenImage> get values => [a404];
}

class $AssetsJsGen {
  const $AssetsJsGen();

  /// File path: assets/js/psl.min.js
  String get pslMin => 'assets/js/psl.min.js';

  /// File path: assets/js/radar-rules-ios.js
  String get radarRulesIos => 'assets/js/radar-rules-ios.js';

  /// File path: assets/js/radar-rules.js
  String get radarRules => 'assets/js/radar-rules.js';

  /// File path: assets/js/route-recognizer.min.js
  String get routeRecognizerMin => 'assets/js/route-recognizer.min.js';

  /// File path: assets/js/url.min.js
  String get urlMin => 'assets/js/url.min.js';

  /// File path: assets/js/utils.js
  String get utils => 'assets/js/utils.js';

  /// List of all assets
  List<String> get values =>
      [pslMin, radarRulesIos, radarRules, routeRecognizerMin, urlMin, utils];
}

class Assets {
  Assets._();

  static const $AssetsImgsGen imgs = $AssetsImgsGen();
  static const $AssetsJsGen js = $AssetsJsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size = null});

  final String _assetName;

  final Size? size;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
