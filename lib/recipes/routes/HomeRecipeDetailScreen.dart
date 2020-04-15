import 'package:flutter/material.dart';
import 'package:recipes_app_flutter/recipes/routes/CommentsScreen.dart';
import 'package:recipes_app_flutter/recipes/routes/RecipeDetailScreen.dart';
import 'package:recipes_app_flutter/res/Fonts.dart' as Fonts;

class HomeRecipeDetailScreen extends StatefulWidget {
  final recipeId;
  final tag;
  final recipeName;

  HomeRecipeDetailScreen(
      {Key key,
      @required this.recipeId,
      @required this.recipeName,
      @required this.tag})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeRecipeDetailState();
}

class HomeRecipeDetailState extends State<HomeRecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          // textTheme: TextTheme(title: TextStyle(color: Theme.of(context).accentColor)),
          textTheme: TextTheme(
              title: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 20,
                  fontFamily: Fonts.Metropolis_Regular)),
          bottom: TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Text(
                  'Detail',
                  style: TextStyle(
                      fontSize: 16, fontFamily: Fonts.Metropolis_Bold),
                ),
              ),
              Tab(
                child: Text(
                  'Comments',
                  style: TextStyle(
                      fontSize: 16, fontFamily: Fonts.Metropolis_Bold),
                ),
              ),
            ],
          ),
          title: Text('Recipe'),
        ),
        body: TabBarView(
          children: [
            RecipeDetailScreen(recipeId: widget.recipeId, tag: widget.tag),
            CommentsScreen(recipeId: widget.recipeId)
          ],
        ),
      ),
    );
  }
}
