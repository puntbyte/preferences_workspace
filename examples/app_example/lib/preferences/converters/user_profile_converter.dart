import 'dart:convert';
import 'package:preferences_annotation/preferences_annotation.dart';

class UserProfile {
  final String name;
  final String email;
  UserProfile({required this.name, required this.email});

  // Methods to convert to/from a Map, which is then encoded as a JSON string.
  Map<String, dynamic> toJson() => {'name': name, 'email': email};
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

/// Converts a [UserProfile] object to and from a JSON `String` for storage.
class UserProfileConverter extends PrefConverter<UserProfile, String> {
  const UserProfileConverter();

  @override
  UserProfile fromStorage(String value) =>
      UserProfile.fromJson(jsonDecode(value) as Map<String, dynamic>);

  @override
  String toStorage(UserProfile value) => jsonEncode(value.toJson());
}
