import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

/// Provides convenient extension methods on [DartType] for analysis.
extension DartTypeExtensions on DartType {
  // Type checkers for specific, non-core types.
  static const _dateTimeChecker = TypeChecker.fromUrl('dart:core#DateTime');
  static const _durationChecker = TypeChecker.fromUrl('dart:core#Duration');

  /// Returns `true` if this type represents an enum.
  bool get isEnum => element3?.kind == ElementKind.ENUM;

  /// Returns `true` if this type is a record.
  bool get isRecord => this is RecordType;

  /// Returns `true` if this type is `dart.core.DateTime`.
  bool get isDateTime => element3 != null ? _dateTimeChecker.isExactly(element3!) : false;

  /// Returns `true` if this type is `dart.core.Duration`.
  bool get isDuration => element3 != null ? _durationChecker.isExactly(element3!) : false;

  /// Returns `true` if this type is explicitly nullable (e.g., `String?`).
  bool get isNullable {
    final suffix = nullabilitySuffix;
    return suffix == NullabilitySuffix.question || suffix == NullabilitySuffix.star;
  }
}
