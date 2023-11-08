class User {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateRegistered;
  final String emailAddress;
  final int phoneNumber;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateRegistered,
    required this.emailAddress,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateRegistered: DateTime.parse(json['date_registered']),
      emailAddress: json['email_address'],
      phoneNumber: json['phone_number'],
    );
  }
}
