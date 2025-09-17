import 'dart:ui';
import 'package:preferences_annotation/preferences_annotation.dart';

/// Converts a [Color] object to and from an `int` for storage.
class ColorConverter extends PrefConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromStorage(int value) => Color(value);

  @override
  int toStorage(Color value) => value.toARGB32();
}
