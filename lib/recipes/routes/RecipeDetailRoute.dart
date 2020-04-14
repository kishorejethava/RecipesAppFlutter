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
import 'package:recipes_app_flutter/utils/model/ResMessage.dart';
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
  File imageFile;
  var isPhotoUploading = false;
  var isPhotoUpdated = false;
  var _progressValue = 0.0;
  var inCookingList = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipe Detail')),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Visibility(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                              value: _progressValue,
                            ),
                            visible: isPhotoUploading,
                          ),
                          Container(
                            child: Stack(
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: _decideImageView(),
                                ),
                                Positioned(
                                    right: 12,
                                    top: 12,
                                    child: IconButton(
                                        icon: Icon(
                                          inCookingList
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Theme.of(context).accentColor,
                                          size: 32.0,
                                        ),
                                        onPressed: () {
                                          if (inCookingList)
                                            removeFromCookingList();
                                          else
                                            addToCookingList();
                                        }))
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(12.0),
                            child: Text(
                              recipe.name ?? "",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(12.0),
                            child: Text(
                                'Preparing Time ${recipe.preparationTime ?? ""}',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontFamily: Fonts.Metropolis_Regular)),
                          ),
                          Container(
                            margin: EdgeInsets.all(12.0),
                            child: Text('Serves ${recipe.serves ?? ""}',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontFamily: Fonts.Metropolis_Regular)),
                          ),
                          Container(
                            margin: EdgeInsets.all(12.0),
                            child: Text('Complexity ${recipe.complexity ?? ""}',
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
                          Container(
                            margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                            child: Visibility(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Ingredients',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontFamily: Fonts.Metropolis_Bold)),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    _addIngredientDialog(context);
                                  },
                                ),
                              ],
                            )),
                          ),
                          getIngredientList(_updateMyTitle),
                          Container(
                            margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                            child: Visibility(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Instructions',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontFamily: Fonts.Metropolis_Bold)),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    _addInstructionDialog(context);
                                  },
                                ),
                              ],
                            )),
                          ),
                          getInstructionList(_updateMyTitle),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: getCommentWidget(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getRecipeDetail().then((recipe) {
      setState(() {
        this.recipe = recipe;
        inCookingList = recipe.inCookingList == 1;
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
    if (metaTags != null) {
      for (MetaTag metaTag in metaTags) {
        list.add(Chip(
          label: Text(metaTag.tag ?? ""),
        ));
      }
    }
    return list;
  }

  _updateMyTitle(String title) {
    getRecipeDetail().then((recipe) {
      setState(() {
        this.recipe = recipe;
        inCookingList = recipe.inCookingList == 1;
      });
    });
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

  Future<void> _addIngredientDialog(BuildContext context) {
    final textEditingController = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Ingredient'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                    child: TextFormField(
                      autofocus: true,
                      controller: textEditingController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Ingredient'),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  FlatButton(
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 16.0),
                    splashColor: Colors.redAccent,
                    onPressed: () {
                      Navigator.of(context).pop();
                      addIngredient(textEditingController.text);
                    },
                    child: Text("Add", style: TextStyle(fontSize: 14.0)),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _addInstructionDialog(BuildContext context) {
    final textEditingController = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Instruction'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                    child: TextFormField(
                      autofocus: true,
                      controller: textEditingController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Instruction'),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  FlatButton(
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 16.0),
                    splashColor: Colors.redAccent,
                    onPressed: () {
                      Navigator.of(context).pop();
                      addInstruction(textEditingController.text);
                    },
                    child: Text("Add", style: TextStyle(fontSize: 14.0)),
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

  addToCookingList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url = 'http://35.160.197.175:3006/api/v1/recipe/add-to-cooking-list';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };
    Map data = {'recipeId': widget.recipeId};
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      setState(() {
        inCookingList = true;
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

  addIngredient(String ingredient) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url = 'http://35.160.197.175:3006/api/v1/recipe/add-ingredient';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };
    Map data = {'recipeId': widget.recipeId, 'ingredient': ingredient};
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      _updateMyTitle('done');
      setState(() {
        inCookingList = true;
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

  addInstruction(String instruction) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url = 'http://35.160.197.175:3006/api/v1/recipe/add-instruction';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };
    Map data = {'recipeId': widget.recipeId, 'instruction': instruction};
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      _updateMyTitle('done');
      setState(() {
        inCookingList = true;
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

  removeFromCookingList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url =
        'http://35.160.197.175:3006/api/v1/recipe/rm-from-cooking-list';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };
    Map data = {'recipeId': widget.recipeId};
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      setState(() {
        inCookingList = false;
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

  Widget getIngredientList(Function(String title) _updateMyTitle) {
    if (recipe.ingredients != null && recipe.ingredients.length > 0) {
      return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(
          indent: 12,
          endIndent: 12,
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => IngredientItem(
            recipeId: widget.recipeId,
            ingredient: recipe.ingredients[index],
            parentAction: _updateMyTitle),
        itemCount: recipe.ingredients != null ? recipe.ingredients.length : 0,
      );
    } else {
      return Container(
        margin: EdgeInsets.all(12.0),
        child: Text(
          'Ingredients not available',
          style: TextStyle(fontFamily: Fonts.Metropolis_Regular),
        ),
      );
    }
  }

  Widget getInstructionList(Function(String title) _updateMyTitle) {
    if (recipe.instructions != null && recipe.instructions.length > 0) {
      return ListView.separated(
        separatorBuilder: (BuildContext context, index) => Divider(
          indent: 12,
          endIndent: 12,
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => InstructionItem(
            recipeId: widget.recipeId,
            instruction: recipe.instructions[index],
            parentAction: _updateMyTitle),
        itemCount: recipe.instructions != null ? recipe.instructions.length : 0,
      );
    } else {
      return Container(
        margin: EdgeInsets.all(12.0),
        child: Text(
          'Instructions not available',
          style: TextStyle(fontFamily: Fonts.Metropolis_Regular),
        ),
      );
    }
  }

  Widget getCommentWidget() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TextField(
                decoration: new InputDecoration.collapsed(
                  hintText: 'Add comment',
                  filled: true,
                ),
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: Fonts.Metropolis_Regular),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class IngredientItem extends StatelessWidget {
  final int recipeId;
  final Ingredient ingredient;
  final ValueChanged<String> parentAction;
  const IngredientItem({this.recipeId, this.ingredient, this.parentAction});

  @override
  Widget build(BuildContext context) {
    return _buildListItem();
  }

  Widget _buildListItem() {
    return Container(
      color: Colors.black12,
      margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Text(
              ingredient.value,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: Fonts.Metropolis_Regular),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              removeIngredient(recipeId, ingredient.id);
            },
          )
        ],
      ),
    );
  }

  void removeIngredient(int recipeId, int ingredientId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url = 'http://35.160.197.175:3006/api/v1/recipe/rm-ingredient';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };

    Map data = {
      'ingredientId': ingredientId.toString(),
      'recipeId': recipeId.toString()
    };
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      parentAction('done');
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

class InstructionItem extends StatelessWidget {
  final int recipeId;
  final Instruction instruction;
  final ValueChanged<String> parentAction;
  const InstructionItem({this.recipeId, this.instruction, this.parentAction});

  @override
  Widget build(BuildContext context) {
    return _buildListItem();
  }

  Widget _buildListItem() {
    return Container(
      color: Colors.black12,
      margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Text(
                instruction.instruction,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: Fonts.Metropolis_Regular),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              removeInstruction(recipeId, instruction.id);
            },
          ),
        ],
      ),
    );
  }

  void removeInstruction(int recipeId, int instructionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url = 'http://35.160.197.175:3006/api/v1/recipe/rm-instruction';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };

    Map data = {
      "instructionId": instructionId.toString(),
      "recipeId": recipeId.toString()
    };
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      parentAction('done');
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
