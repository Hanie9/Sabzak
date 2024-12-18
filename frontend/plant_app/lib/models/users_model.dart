class Users{
  late String userId;
  late String firstName;
  late String lastName;
  late String username;
  late String password;
  late String email;
  late bool isadmin;
  late DateTime registrationDate;

  Users({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
    required this.isadmin,
    required this.registrationDate
  });

  factory Users.fromJson(Map<String, dynamic> json){
    return Users(
      userId: json['userid'],
      firstName: json['firstname'],
      lastName: json['lastname'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      isadmin: json['is_admin'],
      registrationDate: DateTime.parse(json['register_date'])
    );
  }
}