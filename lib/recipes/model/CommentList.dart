import 'package:recipes_app_flutter/recipes/model/Comment.dart';

class CommentList {
  final List<Comment> commentList;

  CommentList({this.commentList});

  factory CommentList.fromJson(List<dynamic> parsedJson) {
    List<Comment> commentList = new List<Comment>();
    commentList = parsedJson.map((i) => Comment.fromJson(i)).toList();
    return new CommentList(
      commentList: commentList,
    );
  }
}
