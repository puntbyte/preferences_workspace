import 'package:preferences_generator/src/utils/names.dart';
import 'package:source_gen/source_gen.dart';

/// A record holding all parsed configuration from a `@PrefsModule` annotation.
typedef ModuleConfigs = ({
  bool notifiable,
  String? onWriteErrorExpression,
  String? getter,
  String? setter,
  String? remover,
  String? asyncGetter,
  String? asyncSetter,
  String? asyncRemover,
  String? streamer,
  String? removeAll,
  String? refresh,
});

/// Parses the raw `@PrefsModule` annotation into a [ModuleConfigs] record.
class ModuleConfigParser {
  const ModuleConfigParser();

  ModuleConfigs parse(ConstantReader reader) {
    final notifiable = reader.read(Names.field.notifiable).boolValue;

    final onWriteErrorExpression = _readFunctionExpression(
      reader.read(Names.field.onWriteError),
    );

    return (
      notifiable: notifiable,
      onWriteErrorExpression: onWriteErrorExpression,
      getter: _readNullableString(reader, Names.field.getter),
      setter: _readNullableString(reader, Names.field.setter),
      remover: _readNullableString(reader, Names.field.remover),
      asyncGetter: _readNullableString(reader, Names.field.asyncGetter),
      asyncSetter: _readNullableString(reader, Names.field.asyncSetter),
      asyncRemover: _readNullableString(reader, Names.field.asyncRemover),
      streamer: _readNullableString(reader, Names.field.streamer),
      removeAll: _readNullableString(reader, Names.field.removeAll),
      refresh: _readNullableString(reader, Names.field.refresh),
    );
  }

  /// Reads a `String?` field from a [ConstantReader], returning `null` if the
  /// field itself is null.
  String? _readNullableString(ConstantReader reader, String fieldName) {
    final fieldReader = reader.read(fieldName);
    return fieldReader.isNull ? null : fieldReader.stringValue;
  }

  /// Reads a function reference field and returns its accessor string (e.g.,
  /// `'MyClass._myHandler'`), or `null` if no function was provided.
  String? _readFunctionExpression(ConstantReader reader) {
    if (reader.isNull) return null;
    final accessor = reader.revive().accessor;
    return accessor.isEmpty ? null : accessor;
  }
}
