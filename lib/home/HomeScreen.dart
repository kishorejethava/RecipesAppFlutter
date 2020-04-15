import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:recipes_app_flutter/favorites/FavoriteRecipesScreen.dart';
import 'package:recipes_app_flutter/profile/ProfileScreen.dart';
import 'package:recipes_app_flutter/recipes/model/Recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipes_app_flutter/recipes/model/RecipeList.dart';
import 'package:recipes_app_flutter/recipes/routes/AddRecipeScreen.dart';
import 'package:recipes_app_flutter/recipes/routes/RecipeDetailScreen.dart';
import 'package:recipes_app_flutter/recipes/routes/RecipesScreen.dart';
import 'package:recipes_app_flutter/settings/SettingsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<Recipe> items = [];
  int currentTab = 0;
  final List<Widget> screens = [
    RecipesScreen(),
    FavoriteRecipesScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Recipes')),
      body: IndexedStack(
    index: currentTab,
    children: screens,
  )/* Container(
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.all(4.0),
        color: CupertinoColors.extraLightBackgroundGray,
        child: buildListView(),
      ) */,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddRecipeScreen(recipe: Recipe())),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: /* BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) {
          setState(() {
            currentTab = index;
          });
        }, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
            
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.mail),
            title: new Text('Messages'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('Profile'))
        ],
      ) */
      BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buildChildBottomBar(),
          ),
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
            itemBuilder: (context, index) => ListItem(
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
          onRefresh: _refresh);
    } else {
      PKCardListSkeleton(
        isCircularImage: true,
        isBottomLinesActive: false,
        length: 10,
      );
    }
  }

  buildChildBottomBar() {
    return <Widget>[
      Row(
        children: <Widget>[
          MaterialButton(
            minWidth: 40,
            onPressed: () {
              setState(() {
                if (currentTab != 0) {
                  currentTab = 0;
                }
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.rss_feed,
                    color: currentTab == 0
                        ? Theme.of(context).accentColor
                        : Colors.grey),
                Text(
                  'Feed',
                  style: TextStyle(
                      color: currentTab == 0
                          ? Theme.of(context).accentColor
                          : Colors.grey),
                )
              ],
            ),
          ),
          MaterialButton(
            minWidth: 40,
            onPressed: () {
              setState(() {
                if (currentTab != 1) {
                  currentTab = 1;
                }
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.favorite,
                    color: currentTab == 1
                        ? Theme.of(context).accentColor
                        : Colors.grey),
                Text(
                  'Favorites',
                  style: TextStyle(
                      color: currentTab == 1
                          ? Theme.of(context).accentColor
                          : Colors.grey),
                )
              ],
            ),
          ),
          MaterialButton(
            minWidth: 40,
            onPressed: () {
              setState(() {
                if (currentTab != 2) {
                  currentTab = 2;
                }
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.account_circle,
                    color: currentTab == 2
                        ? Theme.of(context).accentColor
                        : Colors.grey),
                Text(
                  'Profile',
                  style: TextStyle(
                      color: currentTab == 2
                          ? Theme.of(context).accentColor
                          : Colors.grey),
                )
              ],
            ),
          ),
          MaterialButton(
            minWidth: 40,
            onPressed: () {
              setState(() {
                if (currentTab != 3) {
                  currentTab = 3;
                }
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.settings,
                    color: currentTab == 3
                        ? Theme.of(context).accentColor
                        : Colors.grey),
                Text(
                  'Settings',
                  style: TextStyle(
                      color: currentTab == 3
                          ? Theme.of(context).accentColor
                          : Colors.grey),
                )
              ],
            ),
          ),
        ],
      )
    ];
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
                  builder: (context) =>
                      RecipeDetailScreen(recipeId: recipe.recipeId)),
            ).then((onValue) {});
          },
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
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
