import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recipes_app_flutter/home/HomeScreen.dart';
import 'package:recipes_app_flutter/login/LoginWidget.dart';
import 'package:recipes_app_flutter/recipes/routes/RecipesRoute.dart';
import 'package:recipes_app_flutter/res/Fonts.dart' as Fonts;
import 'package:recipes_app_flutter/res/ZigZagClipper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).accentColor,
        body: new Stack(
          //alignment:new Alignment(x, y)
          children: <Widget>[
            new Positioned(
              child: ClipPath(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  color: Color.fromRGBO(226, 55, 68, 1.0),
                ),
                clipper: ZigZagClipper(),
              ),
            ),
            new Positioned(
              top: 40,
              child: ClipPath(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  color: Color.fromRGBO(226, 55, 68, 0.80),
                ),
                clipper: ZigZagClipper(),
              ),
            ),
            new Positioned(
              top: 80,
              child: ClipPath(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  color: Color.fromRGBO(226, 55, 68, 0.60),
                ),
                clipper: ZigZagClipper(),
              ),
            ),
            new Center(
              child: Text(
                'Recipo',
                style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontFamily: Fonts.OpenSans_ExtraBold),
              ),
            )
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigationPage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginWidget()),
      );
    }else{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }
}
