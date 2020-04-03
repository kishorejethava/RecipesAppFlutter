import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:recipes_app_flutter/recipes/model/Recipe.dart';
import 'package:http/http.dart' as http;
import 'package:recipes_app_flutter/recipes/routes/AddRecipeScreen.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipes_app_flutter/res/Fonts.dart' as Fonts;

class RecipeDetailRoute extends StatefulWidget {
  final recipeId;

  RecipeDetailRoute({Key key, @required this.recipeId}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetailRoute> {
  Recipe recipe = new Recipe();
  List<Entry> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipe Detail')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: recipe.photo ?? "",
                errorWidget: (context, url, error) =>
                    Icon(Icons.photo_album, size: 100),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            child: Text(
              recipe.name,
              style: TextStyle(fontSize: 24),
            ),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            child: Text("Preparing Time ${recipe.preparationTime}",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontFamily: Fonts.Metropolis_Regular)),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            child: Text("Serves ${recipe.serves}",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontFamily: Fonts.Metropolis_Regular)),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            child: Text("Complexity ${recipe.complexity}",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontFamily: Fonts.Metropolis_Regular)),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 12,
              children: _buildMetaTagsWidget(recipe.metaTags),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                EntryItem(data[index]),
            itemCount: list.length,
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );
        },
        child: Icon(Icons.edit),
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getRecipeDetail().then((recipe) {
      setState(() {
        this.recipe = recipe;

        for (var i = 0; i < recipe.ingredients.length; i++) {
          Entry entry = new Entry(recipe.ingredients[i].value);
          list.add(entry);
        }
        data[0].children = list;
        list.clear();
        for (var i = 0; i < recipe.instructions.length; i++) {
          Entry entry = new Entry(recipe.instructions[i].instruction);
          list.add(entry);
        }

        data[1].children = list;
      });
    });
  }

  Future<Recipe> getRecipeDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url =
        'http://35.160.197.175:3006/api/v1/recipe/${widget.recipeId}/details';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };
    debugPrint('url:' + url);
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return List<Recipe>.fromJson(json.decode(response.body));
      debugPrint("response: ${response.body}");
      return Recipe.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  _buildMetaTagsWidget(List<MetaTag> metaTags) {
    List<Widget> list = [];
    for (MetaTag metaTag in metaTags) {
      list.add(Chip(
        label: Text(metaTag.tag),
      ));
    }
    return list;
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  List<Entry> children;
}

// The entire multilevel list displayed by this app.
final List<Entry> data = <Entry>[
  Entry(
    'Ingredients',
    <Entry>[],
  ),
  Entry(
    'Instructions',
    <Entry>[],
  )
];

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

/* void main() {
  runApp(ExpansionTileSample());
} */
