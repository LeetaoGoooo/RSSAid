import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282149177),
      surfaceTint: Color(4282149177),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4290572468),
      onPrimaryContainer: Color(4278198788),
      secondary: Color(4285030163),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294043018),
      onSecondaryContainer: Color(4280228864),
      tertiary: Color(4284831119),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4293516799),
      onTertiaryContainer: Color(4280291399),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294441969),
      onSurface: Color(4279835927),
      onSurfaceVariant: Color(4282534208),
      outline: Color(4285692271),
      outlineVariant: Color(4290955709),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281152044),
      inversePrimary: Color(4288795546),
      primaryFixed: Color(4290572468),
      onPrimaryFixed: Color(4278198788),
      primaryFixedDim: Color(4288795546),
      onPrimaryFixedVariant: Color(4280569892),
      secondaryFixed: Color(4294043018),
      onSecondaryFixed: Color(4280228864),
      secondaryFixedDim: Color(4292135025),
      onSecondaryFixedVariant: Color(4283385856),
      tertiaryFixed: Color(4293516799),
      onTertiaryFixed: Color(4280291399),
      tertiaryFixedDim: Color(4291804670),
      onTertiaryFixedVariant: Color(4283252085),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294441969),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294047211),
      surfaceContainer: Color(4293717990),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292928731),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4280306720),
      surfaceTint: Color(4282149177),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283531085),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4283057152),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4286543400),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282988913),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4286344103),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294441969),
      onSurface: Color(4279835927),
      onSurfaceVariant: Color(4282271036),
      outline: Color(4284113239),
      outlineVariant: Color(4285955442),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281152044),
      inversePrimary: Color(4288795546),
      primaryFixed: Color(4283531085),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4281951799),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4286543400),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4284833040),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4286344103),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4284633996),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294441969),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294047211),
      surfaceContainer: Color(4293717990),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292928731),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278200581),
      surfaceTint: Color(4282149177),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280306720),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280754944),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4283057152),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4280751950),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4282988913),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294441969),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280231454),
      outline: Color(4282271036),
      outlineVariant: Color(4282271036),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281152044),
      inversePrimary: Color(4291230397),
      primaryFixed: Color(4280306720),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278596875),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4283057152),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4281478400),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4282988913),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281475929),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294441969),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294047211),
      surfaceContainer: Color(4293717990),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292928731),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288795546),
      surfaceTint: Color(4288795546),
      onPrimary: Color(4278860047),
      primaryContainer: Color(4280569892),
      onPrimaryContainer: Color(4290572468),
      secondary: Color(4292135025),
      onSecondary: Color(4281741568),
      secondaryContainer: Color(4283385856),
      onSecondaryContainer: Color(4294043018),
      tertiary: Color(4291804670),
      onTertiary: Color(4281739101),
      tertiaryContainer: Color(4283252085),
      onTertiaryContainer: Color(4293516799),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279243791),
      onSurface: Color(4292928731),
      onSurfaceVariant: Color(4290955709),
      outline: Color(4287402888),
      outlineVariant: Color(4282534208),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928731),
      inversePrimary: Color(4282149177),
      primaryFixed: Color(4290572468),
      onPrimaryFixed: Color(4278198788),
      primaryFixedDim: Color(4288795546),
      onPrimaryFixedVariant: Color(4280569892),
      secondaryFixed: Color(4294043018),
      onSecondaryFixed: Color(4280228864),
      secondaryFixedDim: Color(4292135025),
      onSecondaryFixedVariant: Color(4283385856),
      tertiaryFixed: Color(4293516799),
      onTertiaryFixed: Color(4280291399),
      tertiaryFixedDim: Color(4291804670),
      onTertiaryFixedVariant: Color(4283252085),
      surfaceDim: Color(4279243791),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480752),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289058973),
      surfaceTint: Color(4288795546),
      onPrimary: Color(4278197251),
      primaryContainer: Color(4285373543),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4292398453),
      onSecondary: Color(4279899904),
      secondaryContainer: Color(4288451138),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4292067839),
      onTertiary: Color(4279961922),
      tertiaryContainer: Color(4288186309),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279243791),
      onSurface: Color(4294573299),
      onSurfaceVariant: Color(4291218881),
      outline: Color(4288587162),
      outlineVariant: Color(4286481787),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928731),
      inversePrimary: Color(4280635685),
      primaryFixed: Color(4290572468),
      onPrimaryFixed: Color(4278195714),
      primaryFixedDim: Color(4288795546),
      onPrimaryFixedVariant: Color(4279385876),
      secondaryFixed: Color(4294043018),
      onSecondaryFixed: Color(4279505152),
      secondaryFixedDim: Color(4292135025),
      onSecondaryFixedVariant: Color(4282201856),
      tertiaryFixed: Color(4293516799),
      onTertiaryFixed: Color(4279632701),
      tertiaryFixedDim: Color(4291804670),
      onTertiaryFixedVariant: Color(4282133603),
      surfaceDim: Color(4279243791),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480752),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294049770),
      surfaceTint: Color(4288795546),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289058973),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294966002),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4292398453),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965759),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4292067839),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279243791),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294442480),
      outline: Color(4291218881),
      outlineVariant: Color(4291218881),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928731),
      inversePrimary: Color(4278399497),
      primaryFixed: Color(4290901176),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289058973),
      onPrimaryFixedVariant: Color(4278197251),
      secondaryFixed: Color(4294306190),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4292398453),
      onSecondaryFixedVariant: Color(4279899904),
      tertiaryFixed: Color(4293780223),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4292067839),
      onTertiaryFixedVariant: Color(4279961922),
      surfaceDim: Color(4279243791),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480752),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
