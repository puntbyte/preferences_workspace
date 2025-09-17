import 'package:preferences_annotation/preferences_annotation.dart';

class UriConverter extends PrefConverter<Uri, String> {
  const UriConverter();

  @override
  Uri fromStorage(String value) => Uri.parse(value);

  @override
  String toStorage(Uri value) => value.toString();
}
