class User {
  final int id;
  final String name;
  final String email;
  final String company;

  User({required this.id, required this.name, required this.email, required this.company});

  // Factory constructor to parse JSON into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      company: json['company']['name'], // Parsing nested JSON
    );
  }
}