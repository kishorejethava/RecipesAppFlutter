class ResLogin {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String token;

  ResLogin({this.id, this.firstName, this.lastName, this.email, this.password, this.token});

  factory ResLogin.fromJson(Map<String, dynamic> json) {
    return ResLogin(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      token: json['token'],
    );
  }
}