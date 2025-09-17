import 'package:analyzer/dart/element/element2.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:source_gen/source_gen.dart';

/// The sealed base class for representing a method's configuration at different stages of the
/// generation process.
sealed class MethodConfig {
  final bool? enabled;
  final String? prefix;
  final String? suffix;
  final String? name;

  const MethodConfig({
    this.enabled,
    this.prefix,
    this.suffix,
    this.name,
  });
}

/// Represents a method's configuration as it is parsed directly from an annotation. All properties
/// are nullable because they may not be specified by the user.
class UnresolvedMethodConfig extends MethodConfig {
  static const _affixChecker = TypeChecker.fromRuntime(AffixConfig);
  static const _namedChecker = TypeChecker.fromRuntime(NamedConfig);

  const UnresolvedMethodConfig({
    super.enabled,
    super.prefix,
    super.suffix,
    super.name,
  });

  /// A robust factory that safely parses any `MethodConfig` subclass from the annotation package
  /// into a unified `UnresolvedMethodConfig`.
  factory UnresolvedMethodConfig.fromReader(ConstantReader reader) {
    if (reader.isNull) return const UnresolvedMethodConfig();

    final object = reader.objectValue;
    final enabledReader = reader.read(Names.field.enabled);
    bool? enabledValue;

    if (enabledReader.isNull) {
      final type = object.type;
      if (type != null &&
          (_affixChecker.isExactlyType(type) || _namedChecker.isExactlyType(type))) {
        enabledValue = true;
      }
    } else {
      enabledValue = enabledReader.boolValue;
    }

    final element = object.type?.element3;
    if (element is! InterfaceElement2) return UnresolvedMethodConfig(enabled: enabledValue);
    final availableFields = element.fields2.map((field) => field.name3).whereType<String>().toSet();

    T? read<T>(String fieldName, T Function(ConstantReader reader) getValue) {
      if (availableFields.contains(fieldName)) {
        final fieldReader = reader.read(fieldName);
        return fieldReader.isNull ? null : getValue(fieldReader);
      }

      return null;
    }

    return UnresolvedMethodConfig(
      enabled: enabledValue,
      prefix: read(Names.field.prefix, (reader) => reader.stringValue),
      suffix: read(Names.field.suffix, (reader) => reader.stringValue),
      name: read(Names.field.name, (reader) => reader.stringValue),
    );
  }
}

/// Represents the final, decided-upon configuration for a generated method after all layering
/// logic has been applied. The `enabled` property is guaranteed to be a non-nullable `bool`.
class ResolvedMethodConfig extends MethodConfig {
  @override
  final bool enabled;

  const ResolvedMethodConfig({
    required this.enabled,
    super.prefix,
    super.suffix,
    super.name,
  });
}
