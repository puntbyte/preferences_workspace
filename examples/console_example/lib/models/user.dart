class User {
  final int id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  /// Creates a User from a Map (typically from JSON).
  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'] as int, name: json['name'] as String, email: json['email'] as String);

  /// Converts the User instance to a Map.
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  @override
  String toString() => 'User(id: $id, name: "$name", email: "$email")';
}
