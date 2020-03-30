import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipes_app_flutter/login/model/LoginResponse.dart';
import 'package:recipes_app_flutter/recipes/routes/RecipesRoute.Dart';

class LoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginWidget> {
  final emailController = TextEditingController()..text = 'jm1@example.com';
  final passwordController = TextEditingController()..text = 'jay@123';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Email required!';
                      }
                      return null;
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Email'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password required!';
                      }
                      return null;
                    },
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Password'),
                  ),
                  SizedBox(height: 40),
                  FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 16.0),
                    splashColor: Colors.blueAccent,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _doLogin().then((loginResponse) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecipesRoute()),
                          );
                        });
                      }
                    },
                    child: Text("Login", style: TextStyle(fontSize: 14.0)),
                  )
                ]),
          )),
    );
  }

  Future<LoginResponse> _doLogin() async {
    String url = 'http://35.160.197.175:3006/api/v1/user/login';
    Map<String, String> headers = {"Content-type": "application/json"};
    Map data = {
      'email': emailController.text,
      'password': passwordController.text
    };
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}
