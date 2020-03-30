import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipes_app_flutter/recipes/model/Recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipes_app_flutter/recipes/model/RecipeList.dart';

class RecipesRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RecipesRouteState();
}

class _RecipesRouteState extends State<RecipesRoute> {
  List<Recipe> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipes')),
      body: Container(
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.all(4.0),
        color: CupertinoColors.extraLightBackgroundGray,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              child: Row(
                children: <Widget>[
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                    imageUrl: items[index].photo ?? "",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.photo_album, size: 100,),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.all(10),
                          child: Text(items[index].name)),
                      Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                              "Chef : ${items[index].firstName}' '${items[index].lastName}"))
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getRecipes().then((onValue) {
      setState(() {
        items = onValue.recipeList;
      });
    });
  }

  Future<RecipeList> getRecipes() async {
    String url = 'http://35.160.197.175:3006/api/v1/recipe/feeds';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization":
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Mn0.MGBf-reNrHdQuwQzRDDNPMo5oWv4GlZKlDShFAAe16s"
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return List<Recipe>.fromJson(json.decode(response.body));
      debugPrint("response: ${response.body}");
      return RecipeList.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}
