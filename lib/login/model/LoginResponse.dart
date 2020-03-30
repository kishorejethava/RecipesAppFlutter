class LoginResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String token;

  LoginResponse({this.id, this.firstName, this.lastName, this.email, this.password, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      token: json['token'],
    );
  }
}