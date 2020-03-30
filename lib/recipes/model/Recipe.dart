 
 class Recipe {
  final int recipeId;
  final String ytUrl;
  final String name;
  final String photo;
  final String preparationTime;
  final String serves;
  final String complexity;
  final String firstName;
  final String lastName;
  final int inCookingList;

  Recipe({this.recipeId, 
  this.ytUrl, this.name, 
  this.photo, this.preparationTime, 
  this.serves, this.complexity, 
  this.firstName, this.lastName, 
  this.inCookingList});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipeId'],
      ytUrl: json['ytUrl'],
      name: json['name'],
      photo: json['photo'],
      preparationTime: json['preparationTime'],
      serves: json['serves'],
      complexity: json['complexity'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      inCookingList: json['inCookingList'],
    );
  }
}