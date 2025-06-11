import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

/// Provides convenient extension methods on [DartType] for analysis.
extension DartTypeExtensions on DartType {
  // Type checkers for specific, non-core types.
  static const _dateTimeChecker = TypeChecker.fromUrl('dart:core#DateTime');
  static const _colorChecker = TypeChecker.fromUrl('dart:ui#Color');

  /// Returns `true` if this type represents an enum.
  bool get isEnum => element?.kind == ElementKind.ENUM;

  /// Returns `true` if this type is a record.
  bool get isRecord => this is RecordType;

  /// Returns `true` if this type is `dart.ui.Color`.
  bool get isColor => element != null ? _colorChecker.isExactly(element!) : false;

  /// Returns `true` if this type is `dart.core.DateTime`.
  bool get isDateTime => element != null ? _dateTimeChecker.isExactly(element!) : false;

  bool get isNullable => toString().endsWith("?");
}