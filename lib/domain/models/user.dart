class User {
  final String phone;
  final String fullName;
  final String email;
  final String city;

  const User({
    required this.phone,
    required this.fullName,
    required this.email,
    required this.city,
  });

  User copyWith({
    String? phone,
    String? fullName,
    String? email,
    String? city,
  }) {
    return User(
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      city: city ?? this.city,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phone: json['phone'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      city: json['city'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'fullName': fullName,
    'email': email,
    'city': city,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          fullName == other.fullName &&
          email == other.email &&
          city == other.city;

  @override
  int get hashCode => Object.hash(phone, fullName, email, city);

  @override
  String toString() =>
      'User(phone: $phone, fullName: $fullName, email: $email, city: $city)';
}
