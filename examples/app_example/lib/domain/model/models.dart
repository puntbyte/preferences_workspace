
class UserProfile {
  final String email;
  final int? age;
  final List<String> interests;

  UserProfile({required this.email, this.age, this.interests = const []});

  Map<String, dynamic> toJson() => {
    'email': email,
    if (age != null) 'age': age,
    'interests': interests,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    email: json['email'] as String,
    age: json['age'] as int?,
    interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}