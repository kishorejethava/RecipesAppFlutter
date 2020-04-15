class Comment {
  final int id;
  final String comment;
  final String createdAt;
  final String firstName;
  final String lastName;

  Comment(
      {this.id, this.comment, this.createdAt, this.firstName, this.lastName});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      comment: json['comment'],
      createdAt: json['createdAt'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}
