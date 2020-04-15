import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:recipes_app_flutter/recipes/model/Recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipes_app_flutter/recipes/model/RecipeList.dart';
import 'package:recipes_app_flutter/recipes/routes/HomeRecipeDetailScreen.dart';
import 'package:recipes_app_flutter/utils/model/ResMessage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RecipesRouteState();
}

class _RecipesRouteState extends State<RecipesScreen> with RouteAware {
  List<Recipe> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: FeedSearchDelegate(items: items));
              })
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.all(4.0),
        color: CupertinoColors.extraLightBackgroundGray,
        child: buildListView(),
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    debugPrint("didPopNext ${runtimeType}");
  }

  // Called when the current route has been pushed.
  void didPush() {
    debugPrint("didPush ${runtimeType}");
  }

  // Called when the current route has been popped off.
  void didPop() {
    debugPrint("didPop ${runtimeType}");
  }

  // Called when a new route has been pushed, and the current route is no longer visible.
  void didPushNext() {
    debugPrint("didPushNext ${runtimeType}");
  }

  Future<RecipeList> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url = 'http://35.160.197.175:3006/api/v1/recipe/feeds';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
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

  Future<void> _refresh() {
    return getRecipes().then((onValue) {
      setState(() {
        items = onValue.recipeList;
      });
    });
  }

  buildListView() {
    if (items.length > 0) {
      return RefreshIndicator(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              onDismissed: (DismissDirection direction) {
                removeRecipe(index);
              },
              child: ListItem(
                  index: index,
                  recipe: items[index],
                  callback: (val) {
                    getRecipes().then((onValue) {
                      setState(() {
                        items = onValue.recipeList;
                      });
                    });
                  }),
            ),
          ),
          onRefresh: _refresh);
    } else {
      PKCardListSkeleton(
        isCircularImage: true,
        isBottomLinesActive: false,
        length: 10,
      );
    }
  }

  removeRecipe(var index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url =
        'http://35.160.197.175:3006/api/v1/recipe/${items[index].recipeId}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      setState(() {
        this.items.removeAt(index);
      });
      Fluttertoast.showToast(
        msg: ResMessage.fromJson(json.decode(response.body)).msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}

typedef void Callback(String val);

class ListItem extends StatelessWidget {
  final int index;
  final Recipe recipe;
  final Callback callback;

  const ListItem({Key key, this.index, this.recipe, this.callback});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeRecipeDetailScreen(
                        recipeId: recipe.recipeId,
                        recipeName: recipe.name,
                        tag: 'recipe$index',
                      )),
            ).then((onValue) {});
          },
          child: Row(
            children: <Widget>[
              Hero(
                tag: 'recipe$index',
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: 100,
                  width: 100,
                  imageUrl: recipe.photo ?? "",
                  placeholder: (context, url) => Image.asset(
                    'assets/images/recipe_place_holder.jpg',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Text(recipe.name,
                            maxLines: 2,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis)),
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                            "Chef : ${recipe.firstName} ${recipe.lastName}"))
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class FeedSearchDelegate extends SearchDelegate<String> {
  List<Recipe> items = [];

  FeedSearchDelegate({Key key, @required this.items});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? items
        : items.where((p) => p.name.toLowerCase().contains(query)).toList();
    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.all(4.0),
      color: CupertinoColors.extraLightBackgroundGray,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) => Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) {},
          child: ListItem(
            index: index,
            recipe: suggestions[index],
          ),
        ),
      ),
    );
  }
}
