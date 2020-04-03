class ResAddRecipe {
  int id;
  String msg;

  ResAddRecipe({this.id, this.msg});

  factory ResAddRecipe.fromJson(Map<String, dynamic> json) {
    return ResAddRecipe(id: json['id'], msg: json['msg']);
  }
}
