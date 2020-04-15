import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:recipes_app_flutter/recipes/model/Comment.dart';
import 'package:recipes_app_flutter/recipes/model/CommentList.dart';
import 'package:recipes_app_flutter/utils/model/ResMessage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:recipes_app_flutter/res/Fonts.dart' as Fonts;

class CommentsScreen extends StatefulWidget {
  final recipeId;
  CommentsScreen({Key key, @required this.recipeId}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CommentsState();
}

class CommentsState extends State<CommentsScreen> {
  List<Comment> items = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8.0),
        color: CupertinoColors.extraLightBackgroundGray,
        child: buildListView(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getComments().then((onValue) {
      setState(() {
        items = onValue.commentList;
      });
    });
  }

  Future<void> _refresh() {
    return getComments().then((onValue) {
      setState(() {
        items = onValue.commentList;
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
                deleteComment(index);
              },
              child: ListItem(
                index: index,
                comment: items[index],
              ),
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

  deleteComment(var index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url =
        'http://35.160.197.175:3006/api/v1/recipe/${widget.recipeId}/comments/${items[index].id}';
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

  Future<CommentList> getComments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url =
        'http://35.160.197.175:3006/api/v1/recipe/${widget.recipeId}/comments';
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
      return CommentList.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}

class ListItem extends StatelessWidget {
  final int index;
  final Comment comment;

  const ListItem({Key key, this.index, this.comment});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () {},
          child: Row(
            children: <Widget>[
              Icon(
                Icons.account_box,
                size: 72,
                color: Colors.grey,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Text("${comment.firstName} ${comment.lastName}",
                            maxLines: 2,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis)),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 2, 10, 10),
                      child: Text(
                        comment.comment,
                        style: TextStyle(fontSize: 13),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
