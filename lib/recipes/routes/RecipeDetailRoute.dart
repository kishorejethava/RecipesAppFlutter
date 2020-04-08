import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipes_app_flutter/recipes/model/Recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipes_app_flutter/res/Fonts.dart' as Fonts;
import 'package:http_parser/http_parser.dart';

class RecipeDetailRoute extends StatefulWidget {
  final recipeId;

  RecipeDetailRoute({Key key, @required this.recipeId}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetailRoute> {
  Recipe recipe = new Recipe();
  List<Entry> list = [];
  File imageFile;
  var isPhotoUploading = false;
  var isPhotoUpdated = false;
  var _progressValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Recipe Detail')),
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    value: _progressValue,
                  ),
                  visible: isPhotoUploading,
                ),
                Container(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _decideImageView(),
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
            Positioned(
              child: FloatingActionButton(
                onPressed: () {
                  _showPickerDialog(context);
                },
                child: Icon(Icons.edit),
                backgroundColor: Theme.of(context).accentColor,
              ),
              right: 20,
              top: 204,
            )
          ],
        ));
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

  Widget _decideImageView() {
    if (!isPhotoUpdated) {
      return CachedNetworkImage(
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
      );
    } else if (imageFile != null) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/recipe_place_holder.jpg',
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _showPickerDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Take a action!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                      child: Text('Gallery'),
                    ),
                    onTap: () {
                      _openGallery(context).then((file) {
                        if (file != null) addUpdateRecipePhoto();
                      });
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text('Camera'),
                    onTap: () {
                      _openCamera(context).then((file) {
                        if (file != null) addUpdateRecipePhoto();
                      });
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<File> _openGallery(BuildContext context) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (imageFile != null) {
        this.imageFile = imageFile;
        this.isPhotoUpdated = true;
        this.isPhotoUploading = true;
      }
    });
    Navigator.of(context).pop();

    return imageFile;
  }

  Future<File> _openCamera(BuildContext context) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (imageFile != null) {
        this.imageFile = imageFile;
        this.isPhotoUpdated = true;
        this.isPhotoUploading = true;
      }
    });
    Navigator.of(context).pop();

    return imageFile;
  }

  addUpdateRecipePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    var dio = Dio();
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "recipeId": widget.recipeId.toString(),
      "photo": await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: new MediaType("image", "jpeg"),
      ),
    });

    var response = await dio.post(
      "http://35.160.197.175:3006/api/v1/recipe/add-update-recipe-photo",
      data: formData,
      options: Options(
        headers: {"Authorization": token},
      ),
      onSendProgress: (int sent, int total) {
        debugPrint("sent${(sent / total * 100) / 100}");
        setState(() {
          _progressValue = sent / total * 100;
        });
      },
    ).whenComplete(() {
      setState(() {
        imageFile = imageFile;
        isPhotoUploading = false;
      });
    }).catchError((onError) {
      debugPrint("error:${onError.toString()}");
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return ResUploadPhoto.fromJson(json.decode(response.body));
      debugPrint("complete:${response.data.toString()}");
      Fluttertoast.showToast(
        msg: "Uploaded!",
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
      debugPrint("Response upload photo: $response");
      throw Exception('Failed to load album');
    }
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
